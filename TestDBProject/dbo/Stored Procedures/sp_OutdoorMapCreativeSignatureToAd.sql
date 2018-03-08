

-- ====================================================================================================================== 
-- Author			: Karunakar
-- Create date		: 06th July 2015
-- Description		: This Procedure is Used to Mapping  on Ad to CreativeSignature
-- Updated By		: Ramesh On 08/12/2015  - CleanUp for OneMTDB 
--					  Arun Nair on 09/02/2015 -Added CreateBy,ModifiedBy,Update CreativeSignature in PatternMaster
--					  Arun Nair on 10/12/2015 - Append Description with MODReason
--					:L.E. on 1/31/2017 - Added check to update Pattern table if record exists MI-953
-- =======================================================================================================================
CREATE PROCEDURE [dbo].[sp_OutdoorMapCreativeSignatureToAd] 
(
 @Description       AS NVARCHAR(max), 
 @RecutDetail       AS NVARCHAR(max), 
 @Adid              INT, 
 @CreativeSignature AS NVARCHAR(MAX),
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

          DECLARE @OccurrenceID AS INT=0 
          DECLARE @CreativeMasterID AS INT=0 
          DECLARE @PatternMasterID AS INT=0 
          DECLARE @CreativeStagingID AS INT=0           
          DECLARE @NumberRecords AS INT=0 
          DECLARE @RowCount AS INT=0 
          DECLARE @MediaStream AS INT=0 

          SELECT @mediastream = configurationid FROM   [Configuration] WHERE  systemname = 'ALL' AND componentname = 'media stream' AND valuetitle = 'Outdoor' 

          PRINT( 'Mediastream - ' + Cast(@mediastream AS VARCHAR) ) 

          --Index the creative signature to ad 
          

          CREATE TABLE #tempoccurencesforcreativesignature 
            ( 
               rowid        INT IDENTITY(1, 1), 
               occurrenceid INT 
            ) 

          INSERT INTO #tempoccurencesforcreativesignature (occurrenceid)
          SELECT  [OccurrenceDetailODRID] FROM    [dbo].[OccurrenceDetailODR] Where [OccurrenceDetailODR].ImageFileName= @CreativeSignature 

          DECLARE @primaryOccurrenceID AS INTEGER 

          SELECT @primaryOccurrenceID = Min(occurrenceid) FROM   #tempoccurencesforcreativesignature 

		  PRINT 'primaryoccurrenceid'
          PRINT ( 'primaryoccurrenceid-' + Cast(@primaryOccurrenceID AS VARCHAR) ) 

          IF EXISTS(SELECT * FROM   [CreativeStaging]  WHERE  [OccurrenceID] = @primaryOccurrenceID) 
            BEGIN 
                --- Get data from [CREATIVEMASTER]  
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

                PRINT( 'creativemaster id-'  + Cast(@CreativeMasterID AS VARCHAR) ) 

                ---Get data from [CREATIVEMASTERSTAGING]
				
				SELECT @CreativeStagingID = [CreativeStaging].[CreativeStagingID]  FROM   [CreativeStaging] 
				inner join [CreativeDetailStagingODR] on [CreativeStaging].[CreativeStagingID]=[CreativeDetailStagingODR].CreativeStagingID 
				WHERE [CreativeStaging].[OccurrenceID] = @primaryOccurrenceID
				  
               

                INSERT INTO creativedetailODR 
                            (creativemasterid, 
                             creativeassetname, 
                             creativerepository, 
                             legacycreativeassetname, 
                             creativefiletype,
							 AdFormatId) 
                SELECT @CreativeMasterID, 
                       [CreativeAssetName], 
                       [CreativeRepository], 
                       '', 
                       [CreativeFileType],
					   [AdFormatId] 
                FROM   [CreativeDetailStagingODR]
                WHERE  [CreativeStagingID]= @CreativeStagingID  

                PRINT ( 'creativedetailsra - inserted' ) 
            END 

         
		 	---Get Pattern ID into @PatternMasterID from [PATTERNSTAGING] used for OccuranceDetailODR update as well 
			

			SELECT @PatternMasterID=PatternID FROM [dbo].[PatternStaging] WHERE  [CreativeSignature] = @CreativeSignature
			--L.E. on 1/31/2017
			IF EXISTS (SELECT TOP 1 * FROM PATTERN WHERE PATTERNID=@PatternMasterID)
			BEGIN 
				UPDATE [Pattern]  
				SET [CreativeID]=@CreativeMasterID, [AdID]=@adid, MediaStream=@MediaStream, [Pattern].[Exception]=[PatternStaging].[Exception],
					[Pattern].[Query]=[PatternStaging].[Query], [status]= 'Valid', 
					 LastMappedDate=getdate(),LastMapperInits =@userId,
					ModifiedBy=@UserID, ModifyDate=getDate(),CreativeSignature=@CreativeSignature
				FROM [Pattern]  
				INNER JOIN [PatternStaging] on [Pattern].PatternID= [PatternStaging].PatternID
				where [Pattern].PatternID =@PatternMasterID and [Pattern].[CreativeSignature] = @CreativeSignature 
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
						   ModifyDate,
						   CreativeSignature,
						   LastMappedDate,LastMapperInits) 
			  SELECT @CreativeMasterID, 
					 @adid, 
					 @MediaStream, 
					 [Exception], 
					 [Query],  
					 'Valid',                          -- Status Value HardCoded
					 @UserId,
					 Getdate(), 
					 NULL,
					 NULL,
					 @CreativeSignature,GetDate(),@UserID
			  FROM   [dbo].[PatternStaging] 
			  WHERE  [CreativeSignature] = @CreativeSignature 
				
				PRINT( 'patternmaster - inserted' ) 

				SET @PatternMasterID=Scope_identity();  --get new patternid
			END



          PRINT( 'patternmasterid-' + Cast(@PatternMasterID AS VARCHAR) ) 
          PRINT( 'creative signature-' + @creativesignature ) 		   
		  print ('executed')
          SELECT @NumberRecords = Count(*) 
          FROM   #tempoccurencesforcreativesignature 

          --SET @RowCount = 1 

          --WHILE @RowCount <= @NumberRecords 
          --  BEGIN 
          --      --- Get OccurrenceID's from Temporary table  
          --      SELECT @OccurrenceID = [occurrenceid] 
          --      FROM   #tempoccurencesforcreativesignature 
          --      WHERE  rowid = @RowCount 
          --      PRINT( 'occurrenceid-'  + Cast(@OccurrenceID AS VARCHAR) ) 

          --      ----Update PatternMasterID and Ad into OCCURRENCEDETAILODR Table				    
          --      UPDATE [dbo].[OccurrenceDetailODR] SET    [PatternID] = @PatternMasterID,[AdID] = @AdID WHERE  [OccurrenceDetailODRID] = @OccurrenceID  

          --      SET @RowCount=@rowcount + 1 
          --  END 
		  print '[OccurrenceDetailODR] update '
		   ----Update PatternMasterID and Ad into OCCURRENCEDETAILODR Table				    
                UPDATE a SET a.[PatternID] = @PatternMasterID,[AdID] = @AdID 
			 FROM  [dbo].[OccurrenceDetailODR] a inner join #tempoccurencesforcreativesignature b on a.[OccurrenceDetailODRID] = b.[occurrenceid]

			-- update QueryDetail
		    update [QueryDetail]
		    set [PatternMasterId] = @PatternMasterID, [PatternStgId] = null
		    where [PatternStgId] = (select [PatternStagingId] from [PatternStaging] where [PatternId] = @PatternMasterID)
		  
		  --Remove record from PatternDetailsRAStaging and CreativeDetailsRAStaging which are moved to PatternMaster and CreativeMaster 						
		  DELETE FROM [dbo].[PatternStaging] WHERE [CreativeStgID] = @CreativeStagingID 
		  DELETE FROM [dbo].[CreativeDetailStagingODR] WHERE CreativeStagingID = @CreativeStagingID 
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

			-- Deleting Creative Signature from PatternMasterStagingODR

			Exec sp_OutdoorDeleteCreativeSignaturefromQueue @CreativeSignature


          DROP TABLE #tempoccurencesforcreativesignature 

          COMMIT TRANSACTION 
      END TRY 

      BEGIN CATCH 
          DECLARE @error   INT, @message VARCHAR(4000), @lineNo  INT 
          SELECT @error = Error_number(), @message = Error_message(), @lineNo = Error_line() 
          RAISERROR ('[sp_OutdoorMapCreativeSignatureToAd]: %d: %s',16,1,@error,  @message ,@lineNo); 
          ROLLBACK TRANSACTION 
      END CATCH 
  END