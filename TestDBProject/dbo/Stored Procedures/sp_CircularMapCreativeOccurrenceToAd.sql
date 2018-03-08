

-- ====================================================================================================================== 
-- Author			: Lisa
-- Create date		: 10th October 2017
-- Description		: This Procedure is Used to Map and occurrence to and Ad
-- Updated By		:
-- =======================================================================================================================
CREATE PROCEDURE [dbo].[sp_CircularMapCreativeOccurrenceToAd] 
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

          --DECLARE @OccurrenceID AS INT=0 
          DECLARE @CreativeMasterID AS INT=0 
          DECLARE @PatternMasterID AS INT=0 
          DECLARE @CreativeStagingID AS INT=0           
          DECLARE @NumberRecords AS INT=0 
          DECLARE @RowCount AS INT=0 
          DECLARE @MediaStream AS INT=0 

          SELECT @mediastream = configurationid FROM   [Configuration] WHERE  systemname = 'ALL' AND componentname = 'media stream' AND valuetitle = 'Circular' 

          PRINT( 'Mediastream - ' + Cast(@mediastream AS VARCHAR) ) 

          DECLARE @primaryOccurrenceID AS INTEGER 

	    SELECT @primaryOccurrenceID = @OccurrenceID
          PRINT ( 'primaryoccurrenceid-' + Cast(@primaryOccurrenceID AS VARCHAR) ) 


     
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

      
				  

---- do i use the images from the ad?
               
                --INSERT INTO creativedetailEM 
                --            (creativemasterid, 
                --             creativeassetname, 
                --             creativerepository, 
                --             legacyassetname, 
                --             creativefiletype,Deleted,PageNumber,PageTypeId) 
                --SELECT @CreativeMasterID, 
                --       [CreativeAssetName], 
                --       [CreativeRepository], 
                --       '', 
                --       [CreativeFileType],Deleted,PageNumber,PageTypeId 
                --FROM   [CreativeDetailStagingEM]
                --WHERE  [CreativeStagingID]= @CreativeStagingID  


                --PRINT ( 'creativedetailsEM - inserted' ) 
        

			SELECT @PatternMasterID=PatternID FROM OccurrenceDetailCIR WHERE  OccurrenceDetailCIRID = @OccurrenceID
			--L.E. on 1/31/2017
			IF EXISTS (SELECT TOP 1 * FROM PATTERN WHERE PatternID =@PatternMasterID)
			BEGIN 
				UPDATE [Pattern]  
				SET [CreativeID]=@CreativeMasterID, [AdID]=@adid, MediaStream=@MediaStream, [status]= 'Valid', 
					ModifiedBy=@UserID, ModifyDate=Getdate(),LastMappedDate=GetDate(),LastMapperInits=@UserId
				FROM [Pattern]  
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
					 NULL, 
					 NULL,  
					 'Valid',                          -- Status Value HardCoded
					 @UserId,
					 Getdate(), 
					 NULL,
					 NULL
				
				PRINT( 'patternmaster - inserted' ) 

				SET @PatternMasterID=Scope_identity();  --get new patternid
			END


					IF EXISTS (SELECT TOP 1 * FROM [dbo].[OccurrenceDetailCIR]  WHERE [OccurrenceDetailCIRID] = @primaryOccurrenceID  AND [AdID] IS NOT NULL) --ADID IS NOT NULL, REMAP AND LEAVE PATTERN DETAILS 
					BEGIN 
										-- for Review Remap 
						UPDATE [dbo].[OccurrenceDetailCIR] 
						SET   [AdID] = @AdID 
						WHERE  [OccurrenceDetailCIRID] = @primaryOccurrenceID  

						UPDATE [Pattern] 
						SET [Pattern].ADID=@AdID
						FROM [OccurrenceDetailCIR]  
						INNER JOIN [Pattern]  ON [Pattern].PATTERNID=[OccurrenceDetailCIR].PATTERNID
						WHERE [OccurrenceDetailCIR].[OccurrenceDetailCIRID] = @primaryOccurrenceID 

						UPDATE [Creative] 
						SET [Creative].ADID=@AdID
						FROM [OccurrenceDetailCIR] 
						INNER JOIN [Creative]  ON [Creative].SOURCEOCCURRENCEID=[OccurrenceDetailCIR].[OccurrenceDetailCIRID] 							
						WHERE [OccurrenceDetailCIR].[OccurrenceDetailCIRID] = @primaryOccurrenceID 
					END
					ELSE
					BEGIN 													----Update PatternMasterID and Ad in the OCCURRENCEDETAILEM Table	
						UPDATE [dbo].[OccurrenceDetailCIR] 
						SET   [AdID] = @AdID, [PatternID] = @PatternMasterID
						WHERE  [OccurrenceDetailCIRID] = @primaryOccurrenceID  
					END


				-- update QueryDetail
		        --update [QueryDetail]
		        --set [PatternMasterId] = @PatternMasterID, [PatternStgId] = null
		        --where [PatternStgId] = (select [PatternStagingId] from [PatternStaging] where [PatternId] = @PatternMasterID)

				--Remove record from PatternDetailsRAStaging and [CreativeDetailStagingEM] which are moved to PatternMaster and CreativeMaster 						
				--DELETE FROM [dbo].[PatternStaging] WHERE [CreativeStgID] = @CreativeStagingID 
				--DELETE FROM [dbo].[CreativeDetailStagingEM] WHERE CreativeStagingID = @CreativeStagingID 
				--DELETE FROM [dbo].[CreativeStaging] WHERE [CreativeStagingID] = @CreativeStagingID
  

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
          RAISERROR ('[sp_CircularMapCreativeOccurrenceToAd]: %d: %s',16,1,@error,  @message ,@lineNo); 
          ROLLBACK TRANSACTION 
      END CATCH 
  END