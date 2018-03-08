﻿

-- ====================================================================================================================== 
-- Author			: Lisa EAST
-- Create date		: 01/11/17
-- Description		: This Procedure is Used to Mapping  on Ad to SOCIAL OCCURRENCE
-- Updated By		: 
-- =======================================================================================================================
CREATE PROCEDURE [dbo].[sp_SocialMapCreativeOccurrenceToAd] 
(
 @Description       AS NVARCHAR(max), 
 @RecutDetail       AS NVARCHAR(max), 
 @Adid              INT, 
 @OccurrenceID AS INT,
 @UserID            AS INT
) 
AS 
    IF 1 = 0 
      BEGIN 
          SET fmtonly OFF 
      END 

  BEGIN 
      SET nocount ON; 

      BEGIN TRY 
          BEGIN TRANSACTION 

       
          DECLARE @CreativeMasterID AS INT=0 
          DECLARE @PatternMasterID AS INT=0 
          DECLARE @CreativeStagingID AS INT=0           
          DECLARE @NumberRecords AS INT=0 
          DECLARE @RowCount AS INT=0 
          DECLARE @MediaStream AS INT=0 

          SELECT @mediastream = configurationid FROM   [Configuration] WHERE  systemname = 'ALL' AND componentname = 'media stream' AND valuetitle = 'Social Brand' 

          PRINT( 'Mediastream - ' + Cast(@mediastream AS VARCHAR) ) 

   
          DECLARE @primaryOccurrenceID AS INTEGER 

      
	    SELECT @primaryOccurrenceID = @OccurrenceID
          PRINT ( 'primaryoccurrenceid-' + Cast(@primaryOccurrenceID AS VARCHAR) ) 


          IF EXISTS(SELECT * FROM   [CreativeStaging]  WHERE  [OccurrenceID] = @primaryOccurrenceID) 
            BEGIN 
                --- Get data from [CREATIVEMASTER]  
				IF NOT EXISTS(SELECT PK_Id FROM [Creative] WHERE AdId=@ADID)
				BEGIN
					INSERT INTO [Creative] 
							  ([AdId], 
							   [SourceOccurrenceId], 
							   CheckInOccrncs, 
							   PrimaryIndicator) 
					SELECT @ADID, 
						   @primaryOccurrenceID, 
						   1, 
						   0 
				   
					PRINT( 'creativemaster - inserted' ) 
					SELECT @CreativeMasterID = Scope_identity() 
				END
				ELSE
				BEGIN
					SELECT @CreativeMasterID = PK_Id FROM [Creative] WHERE AdId=@ADID
				END
                PRINT( 'creativemaster id-'  + Cast(@CreativeMasterID AS VARCHAR) ) 

                ---Get data from [CREATIVEMASTERSTAGING]
				
				SELECT distinct @CreativeStagingID = [CreativeStaging].[CreativeStagingID]  FROM   [CreativeStaging] 
				inner join [CreativeDetailStagingSOC] on [CreativeStaging].[CreativeStagingID]=[CreativeDetailStagingSOC].CreativeStagingMasterID 
				WHERE [CreativeStaging].[OccurrenceID] = @primaryOccurrenceID
				  
               
		

                INSERT INTO creativedetailSOC 
                            (creativemasterid, 
                             creativeassetname, 
                             creativerepository, 
                             legacyassetname, 
                             creativefiletype,Deleted,PageNumber,PageTypeId) 
                SELECT @CreativeMasterID, 
                       [CreativeAssetName], 
                       [CreativeRepository], 
                       '', 
                       [CreativeFileType] ,null,null,null 
                FROM   [CreativeDetailStagingSOC]
                WHERE  [CreativeStagingMasterID]= @CreativeStagingID  


                PRINT ( 'creativedetailsEM - inserted' ) 
            END 

        
		 	---Get Pattern ID into @PatternMasterID from [PATTERNSTAGING] used for OccuranceDetailEM update as well 
			

			SELECT @PatternMasterID=PatternID FROM [dbo].[PatternStaging] WHERE  CreativeStgID = @CreativeStagingID
			--L.E. on 1/31/2017
			IF EXISTS (SELECT TOP 1 * FROM PATTERN WHERE PatternID =@PatternMasterID)
			BEGIN 
				UPDATE [Pattern]  
				SET [CreativeID]=@CreativeMasterID, [AdID]=@adid, MediaStream=@MediaStream, [Pattern].[Exception]=[PatternStaging].[Exception],
					[Pattern].[Query]=[PatternStaging].[Query], [status]= 'Valid', 
					ModifiedBy=@UserID, ModifyDate=Getdate(),LastMappedDate=GetDate(),LastMapperInits=@UserId
				FROM [Pattern]  
				INNER JOIN [PatternStaging] on [Pattern].PatternID= [PatternStaging].PatternID
				where [Pattern].PatternID =@PatternMasterID
			END 
			ELSE 
			BEGIN 
			  INSERT INTO [Pattern] 
						  ([CreativeID], 
						   [AdID], 
						   MediaStream, 
						   [Exception],  
						   [Query], 
						   Status, 
						   CreateBy,
						   CreateDate,
						   ModifiedBy, 
						   ModifyDate) 
			  SELECT @CreativeMasterID, 
					 @adid, 
					 @MediaStream, 
					 [Exception], 
					 [Query],  
					 'Valid',                          -- Status Value HardCoded
					 @UserId,
					 Getdate(), 
					 NULL,
					 NULL
			  FROM   [dbo].[PatternStaging] 
			  WHERE  creativestgid = @CreativeStagingID
				
				PRINT( 'patternmaster - inserted' ) 

				SET @PatternMasterID=Scope_identity();  --get new patternid
			END

             
		
					IF EXISTS (SELECT TOP 1 * FROM [dbo].[OccurrenceDetailSOC]  WHERE [OccurrenceDetailSOCID] = @primaryOccurrenceID  AND [AdID] IS NOT NULL) --ADID IS NOT NULL, REMAP AND LEAVE PATTERN DETAILS 
					BEGIN 
										-- for Review Remap 
						UPDATE [dbo].[OccurrenceDetailSOC] 
						SET   [AdID] = @AdID 
						WHERE  [OccurrenceDetailSOCID] = @primaryOccurrenceID  

						UPDATE [Pattern] 
						SET [Pattern].ADID=@AdID
						FROM [OccurrenceDetailSOC]  
						INNER JOIN [Pattern]  ON [Pattern].PATTERNID=[OccurrenceDetailSOC].PATTERNID
						WHERE [OccurrenceDetailSOC].[OccurrenceDetailSOCID] = @primaryOccurrenceID 

						UPDATE [Creative] 
						SET [Creative].ADID=@AdID
						FROM [OccurrenceDetailSOC] 
						INNER JOIN [Creative]  ON [Creative].SOURCEOCCURRENCEID=[OccurrenceDetailSOC].[OccurrenceDetailSOCID]							
						WHERE [OccurrenceDetailSOC].[OccurrenceDetailSOCID] = @primaryOccurrenceID 
					END
					ELSE
					BEGIN 													----Update PatternMasterID and Ad in the OCCURRENCEDETAILEM Table	
						UPDATE [dbo].[OccurrenceDetailSOC] 
						SET   [AdID] = @AdID, [PatternID] = @PatternMasterID
						WHERE  [OccurrenceDetailSOCID] = @primaryOccurrenceID  
					END


				-- update QueryDetail
		        update [QueryDetail]
		        set [PatternMasterId] = @PatternMasterID, [PatternStgId] = null
		        where [PatternStgId] = (select [PatternStagingId] from [PatternStaging] where [PatternId] = @PatternMasterID)

				--Remove record from PatternDetailsRAStaging and [CreativeDetailStagingEM] which are moved to PatternMaster and CreativeMaster 						
				DELETE FROM [dbo].[PatternStaging] WHERE [CreativeStgID] = @CreativeStagingID 
				DELETE FROM [dbo].[CreativeDetailStagingSOC] WHERE CreativeStagingMasterID = @CreativeStagingID 
				DELETE FROM [dbo].[CreativeStaging] WHERE [CreativeStagingID] = @CreativeStagingID
  

          -- Update Occurrence in Ad Table  
          UPDATE Ad 
          SET    [PrimaryOccurrenceID] = @primaryOccurrenceID 
          WHERE  [AdID] = @AdID 
                 AND [PrimaryOccurrenceID] IS NULL 

      
         -- PRINT( @mtoreason) 

          IF @Description<>''
			   BEGIN  
			   UPDATE Ad SET    description =description+','+ @Description  WHERE  [AdID] = @AdID
			   END 
			   IF @RecutDetail<>''
			   BEGIN  
			   UPDATE Ad SET    RecutDetail =recutdetail+','+@RecutDetail  WHERE  [AdID] = @AdID
	     END 


			if not exists(select 1 from [Creative] where [AdId]=@adid and PrimaryIndicator=1)
			begin
			-- updated creativemaster primary indicator
			update [Creative] set PrimaryIndicator=1 where [AdId]=@adid	and [SourceOccurrenceId]=@primaryOccurrenceID	
			end

			
          COMMIT TRANSACTION 
      END TRY 

      BEGIN CATCH 
          DECLARE @error   INT, @message VARCHAR(4000), @lineNo  INT 
          SELECT @error = Error_number(), @message = Error_message(), @lineNo = Error_line() 
          RAISERROR ('[sp_EmailMapOccurrenceToAd]: %d: %s',16,1,@error,  @message ,@lineNo); 
          ROLLBACK TRANSACTION 
      END CATCH 
  END