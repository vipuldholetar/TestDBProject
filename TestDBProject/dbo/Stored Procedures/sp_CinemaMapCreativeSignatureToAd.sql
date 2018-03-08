-- ================================================================================================================= 
-- Author			: Karunakar
-- Create date		: 17th July 2015
-- Description		: This Procedure is Used to Mapping  on Ad to CreativeSignature for Cinema
-- Updated By		: Ramesh On 08/12/2015  - CleanUp for OneMTDB 
--					  Arun Nair on 08/24/2015 - For OccurrenceId Change Datatype-Seeding
--					  Arun Nair on 09/02/2015 -Added CreateBy,ModifiedBy,Update CreativeSignature in PatternMaster
--					  Karunakar on 7th Sep 2015
--				   Arun Nair on 10/12/2015 - Append Description with MODReason   
-- ================================================================================================================ 
CREATE PROCEDURE [dbo].[sp_CinemaMapCreativeSignatureToAd] 
(
 @Description       AS NVARCHAR(max), 
 @RecutDetail          AS NVARCHAR(max), 
 @Adid              INT, 
 @CreativeSignature AS VARCHAR(100),
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

				DECLARE @OccurrenceID AS BIGINT=0 
				DECLARE @CreativeMasterID AS INT=0 
				DECLARE @PatternMasterID AS INT=0 
				DECLARE @CreativeStagingID AS INT=0 				
				DECLARE @NumberRecords AS INT=0 
				DECLARE @RowCount AS INT=0 
				DECLARE @MediaStream AS INT=0 
				DECLARE @occurrencemediastream AS VARCHAR(50)

				SELECT @mediastream = configurationid FROM   [Configuration] WHERE  systemname = 'ALL' 
				AND componentname = 'media stream' AND valuetitle = 'Cinema' 

				--PRINT( 'Mediastream - '+ Cast(@mediastream AS VARCHAR) ) 

				--Index the creative signature to ad 
				

				CREATE TABLE #tempoccurencesforcreativesignature 
				( 
				    rowid        INT IDENTITY(1, 1), 
				    mediastream varchar(50),
				    occurrenceid BIGINT 
				) 

				INSERT INTO #tempoccurencesforcreativesignature(occurrenceid,mediastream)
				   SELECT [OccurrenceDetailID],mediastream FROM  [dbo].[vw_OccurrenceDetailAV]
				    --INNER JOIN [CreativeStaging] ON [dbo].[vw_OccurrenceDetailAV].creativesignature = [CreativeStaging].creativesignature 
				    WHERE  [vw_OccurrenceDetailAV].creativesignature = @creativesignature 

				--SELECT  [OccurrenceDetailCINID] FROM    [dbo].[OccurrenceDetailCIN] Where [OccurrenceDetailCIN].[CreativeID]= @CreativeSignature 

				DECLARE @primaryOccurrenceID AS BIGINT 

				SELECT @primaryOccurrenceID = Min(occurrenceid),@occurrencemediastream = mediastream 
				FROM   #tempoccurencesforcreativesignature 
				group by occurrenceid,mediastream

				--PRINT ( 'primaryoccurrenceid-' + Cast(@primaryOccurrenceID AS VARCHAR) ) 

				IF EXISTS(select 1 from [CreativeStaging] a 
						  --inner join  [PatternStaging] b 
						  --on a.[CreativeStagingID]=b.[CreativeStgID] 
						  Where [OccurrenceID] = @primaryOccurrenceID
					   ) 
				BEGIN 
				    --- Inserting data from [CREATIVEMASTER]  
				    INSERT INTO [Creative] 
						    ([AdId], 
							    [SourceOccurrenceId], 
							    CheckInOccrncs, 
							    PrimaryIndicator) 
				    SELECT @ADID, 
					    @primaryOccurrenceID, 
					    1, 
					    0 

				    --PRINT( 'creativemaster - inserted' ) 

				    SELECT @CreativeMasterID = Scope_identity() 

				    --PRINT( 'creativemaster id-' + Cast(@CreativeMasterID AS VARCHAR) ) 

				    ---Get data from [CREATIVEMASTERSTAGING]  

				    SELECT @CreativeStagingID = [CreativeStgID] 
				    FROM   [PatternStaging] 		    
				    WHERE [CreativeSignature] = @CreativeSignature 

				    IF @occurrencemediastream = 'CIN'
				    BEGIN
					   --- Inserting data from [CreativeDetailCIN]  
					   INSERT INTO CreativeDetailCIN 
							   ([CreativeMasterID], 
								   creativeassetname, 
								   creativerepository, 
								   legacycreativeassetname, 
								   creativefiletype) 
					   SELECT @CreativeMasterID, 
						   [CreativeAssetName], 
						   [CreativeRepository], 
						   null, 
						   [CreativeFileType] 
					   FROM   dbo.[CreativeDetailStagingCIN]
					   WHERE  [CreativeStagingID]= @CreativeStagingID  
				    END
				    ELSE IF @occurrencemediastream = 'TV'    
				    BEGIN
					   ---Get data from [CREATIVEMASTERSTAGING]  
					   SELECT @CreativeStagingID = [CreativeStgID] 
						  from   PatternStaging 		    
						  Where [CreativeSignature] = @CreativeSignature 

					   INSERT INTO CreativeDetailCIN 
							   ([CreativeMasterID], 
								   creativeassetname, 
								   creativerepository, 
								   legacycreativeassetname, 
								   creativefiletype) 
					   SELECT @CreativeMasterID, 
							 MediaFileName, 
							 MediaFilepath, 
							 null, 
							 MediaFormat 
					   FROM   [CreativeDetailStagingTV]  WHERE [CreativeDetailStagingTV].MediaFormat='mpg' --Hard Coded Value,to be removed
					   AND  [CreativeStgMasterID]= @CreativeStagingID 
				    END
				    ELSE IF @occurrencemediastream = 'ONV'
				    BEGIN
					   INSERT INTO CreativeDetailCIN 
							 ([CreativeMasterID], 
								creativeassetname, 
								creativerepository, 
								legacycreativeassetname, 
								creativefiletype) 
					   SELECT	@creativemasterid,
								    [dbo].[CreativeDetailStagingONV].[SignatureDefault]+'.'+[dbo].[CreativeDetailStagingONV].CreativeFileType,
								    CreativeRepository, 
								    Null, 
							 CreativeFileType 
					   FROM   CreativeDetailStagingONV
					   WHERE  CreativeStagingID = @CreativeStagingID 
						  And CreativeFileType='MP4' and CreativeDownloaded=1 and FileSize>0  --Updated By Karunakar on 15th October 2015,adding Checks for filesize and filetype
				    END
				--PRINT ( 'creativedetailcin - inserted' ) 
				END 


				--- Inserting data from PatternMaster  
				IF @occurrencemediastream = 'TV'    
				BEGIN
				    INSERT INTO [Pattern] ([CreativeID], [AdID], MediaStream, [Exception],  [Query], Status, CreateBy,CreateDate,ModifiedBy,ModifyDate,CreativeSignature) 
					   SELECT @CreativeMasterID, @adid, @MediaStream, [Exception], [Query],  'Valid',@UserId,Getdate(),NULL,NULL,@CreativeSignature
					   FROM  [dbo].PatternStaging
					   WHERE  [CreativeSignature] = @CreativeSignature
				END
				ELSE
				BEGIN
				    INSERT INTO [Pattern] ([CreativeID], [AdID], MediaStream, [Exception],  [Query], Status, CreateBy,
					    CreateDate,ModifiedBy,ModifyDate,CreativeSignature) 
				    SELECT @CreativeMasterID, @adid, @MediaStream, exception, query,  'Valid', @UserId,Getdate(),
					   NULL,NULL,@CreativeSignature             
				    FROM   [dbo].[PatternStaging] 
				    WHERE  [CreativeSignature] = @CreativeSignature 
				END
				--PRINT( 'patternmaster - inserted' ) 

				SET @PatternMasterID=Scope_identity(); 

				--PRINT( 'patternmasterid-' + Cast(@PatternMasterID AS VARCHAR) ) 
				--PRINT( 'creative signature-' + @creativesignature ) 					   
				--print ('executed')

				--SELECT @NumberRecords = Count(*) FROM   #tempoccurencesforcreativesignature
				--SET @RowCount = 1 
				--WHILE @RowCount <= @NumberRecords 
				--BEGIN 
				--    --- Get OccurrenceID's from Temporary table  
				--    SELECT @OccurrenceID = [occurrenceid] FROM   #tempoccurencesforcreativesignature WHERE  rowid = @RowCount
				--    --PRINT( 'occurrenceid-' + Cast(@OccurrenceID AS VARCHAR) ) 

				--    ----Update PatternMasterID and Ad into OCCURRENCEDETAILCIN Table				    
				--    UPDATE [dbo].[OccurrenceDetailCIN] SET    [PatternID] = @PatternMasterID, [AdID] = @AdID WHERE  [OccurrenceDetailCINID] = @OccurrenceID  

				--    SET @RowCount=@rowcount + 1 
				--END 
				IF @occurrencemediastream = 'CIN'
				BEGIN
				    UPDATE a SET a.[PatternID] = @PatternMasterID, [AdID] = @AdID 
				    FROM [dbo].[OccurrenceDetailCIN] a inner join #tempoccurencesforcreativesignature b on a.[OccurrenceDetailCINID]=b.occurrenceid 
				END
				ELSE IF @occurrencemediastream = 'TV'    
				BEGIN
				    UPDATE a SET a.[PatternID] = @PatternMasterID, [AdID] = @AdID 
					   FROM [dbo].[OccurrenceDetailTV] a inner join #tempoccurencesforcreativesignature b on a.[OccurrenceDetailTVID]=b.[occurrenceid]
				END
				ELSE IF @occurrencemediastream = 'ONV'
				BEGIN
				    UPDATE [dbo].[OccurrenceDetailONV] SET  [PatternID] = @patternmasterid,[AdID] = @adid,[PatternStagingID]=Null  
					   WHERE  [dbo].[OccurrenceDetailONV].CreativeSignature = @creativesignature 
				END
				
				IF @occurrencemediastream = 'CIN'
				BEGIN
				    UPDATE a SET a.[PatternID] = @PatternMasterID, [AdID] = @AdID 
				    FROM [dbo].[OccurrenceDetailCIN] a inner join #tempoccurencesforcreativesignature b on a.[OccurrenceDetailCINID]=b.occurrenceid 
			 
				    DELETE FROM [dbo].[PatternStaging] WHERE [CreativeStgID] = @CreativeStagingID 
				    DELETE FROM [dbo].[CreativeDetailStagingCIN] WHERE [CreativeStagingID] = @CreativeStagingID  
			 
				    Exec sp_CinemaDeleteCreativeSignaturefromQueue @CreativeSignature
				END
				ELSE IF @occurrencemediastream = 'TV'    
				BEGIN
				    UPDATE a SET a.[PatternID] = @PatternMasterID, [AdID] = @AdID 
					   FROM [dbo].[OccurrenceDetailTV] a inner join #tempoccurencesforcreativesignature b on a.[OccurrenceDetailTVID]=b.[occurrenceid]

				    --Remove record from PatternStaging and CreativeDetailsStaging which are moved to PatternMaster and CreativeMaster 
				    DELETE FROM [dbo].[PatternDetailTVStaging] WHERE [PatternStagingID] in   
					   (select a.PatternStagingID   FROM   [dbo].PatternStaging a WHERE  a.[CreativeStgID] = @CreativeStagingID ) 						
				    DELETE FROM [dbo].PatternStaging WHERE [CreativeStgID] = @CreativeStagingID 
				    DELETE FROM [dbo].[CreativeDetailStagingTV] WHERE [CreativeStgMasterID] = @CreativeStagingID 
				END
				ELSE IF @occurrencemediastream = 'ONV'
				BEGIN
				    UPDATE [dbo].[OccurrenceDetailONV] SET  [PatternID] = @patternmasterid,[AdID] = @adid,[PatternStagingID]=Null  
					   WHERE  [dbo].[OccurrenceDetailONV].CreativeSignature = @creativesignature

				    EXEC [sp_OnlineVideoDeleteStagingRecords]   @CreativeStagingID  
				END

				-- Update Occurrence in Ad Table  
          
				UPDATE Ad SET   [PrimaryOccurrenceID] = @primaryOccurrenceID WHERE  [AdID] = @AdID AND [PrimaryOccurrenceID] IS NULL         
				--PRINT( @mtoreason) 

				DELETE FROM [dbo].[CreativeStaging] WHERE [CreativeStagingID] = @CreativeStagingID

				-- Updating MOD Reason Into AD table
			
			 IF @Description<>''
			 BEGIN  
				UPDATE Ad SET    description =description+','+ @Description  WHERE  [AdID] = @AdID
			 END 
			 IF @RecutDetail<>''
			 BEGIN  
				UPDATE Ad SET    RecutDetail =recutdetail+','+@RecutDetail  WHERE  [AdID] = @AdID
			 END 
               -----

			 IF not exists(select 1 from [Creative] where [AdId]=@adid and PrimaryIndicator=1)
			 BEGIN
				-- updated creativemaster primary indicator
				UPDATE [Creative] SET PrimaryIndicator=1 where [AdId]=@adid and [SourceOccurrenceId]=@primaryOccurrenceID	
			 END


			 DROP TABLE #tempoccurencesforcreativesignature 

		  COMMIT TRANSACTION 
      END TRY 

      BEGIN CATCH 
          DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
          SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
          RAISERROR ('[sp_CinemaMapCreativeSignatureToAd]: %d: %s',16,1,@error,@message,@lineNo); 
          ROLLBACK TRANSACTION 
      END CATCH 

  END