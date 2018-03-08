
-- =================================================================================================================      
-- Author		 : Karunakar     
-- Create date   : 09/28/2015
-- Description   : This Procedure is Used to Mapping  on Ad to CreativeSignature for Online Video    
-- Updated By    :
	-- Steps	 :1. Move records from Staging to Core tables     
	--            2. Update PatternMasterID and Ad into OccurrenceDetailsONV for all occurrences of selected creative signature     
	--            2. Update Ad table with MTO reason     
	--            3. Delete records from staging tables after successful movement  
--					  Arun Nair on 10/12/2015 - Append Description with MODReason  
--				: Karunakar on 15th October 2015,
--								1.Adding CreativeDownload and FileSize ,CreativeFileType Check in inserting Query
--								2.Replacing  CreativeAssestname with SignatureDefault and CreativeFileType 
-- ================================================================================================================      
CREATE PROCEDURE [dbo].[sp_OnlineVideoMapCreativeSignatureToAd] --5261,'bf72cc41d726d2708286f14260483d677467cb53',NULL,29712040
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
          SET FMTONLY OFF 
      END 

  BEGIN 
      SET NOCOUNT ON; 

      BEGIN TRY 
          BEGIN TRANSACTION 

          DECLARE @creativemasterid AS INT=0 
          DECLARE @patternmasterid AS INT=0 
          DECLARE @CreativeStagingID AS INT=0           
          DECLARE @mediastream AS INT=0       
          DECLARE @occurrencemediastream AS VARCHAR(50) 
          DECLARE @primaryoccurrenceid AS BIGINT 
		  DECLARE @Patternmasterstgid as int=0

		  CREATE TABLE #tempoccurencesforcreativesignature 
            ( 
               rowid        INT IDENTITY(1, 1), 
			mediastream varchar(50),
               occurrenceid INT 
            ) 

          -- Get Mediastream from configuration master     
          SELECT @mediastream = configurationid FROM   [Configuration] WHERE  systemname = 'ALL' AND componentname = 'Media Stream' AND value = 'ONV' 

          --Get MTO Reason from configuration master      
          
          -- Retrieve Primary occurrence ID     
    --      SELECT @primaryoccurrenceid = Min([dbo].[OccurrenceDetailONV].[OccurrenceDetailONVID]) 
		  --FROM  [dbo].[OccurrenceDetailONV]
		  --INNER JOIN [CreativeStaging] ON [dbo].[OccurrenceDetailONV].creativesignature = [CreativeStaging].creativesignature 
		  --WHERE  [CreativeStaging].creativesignature = @creativesignature 
		        
           INSERT INTO #tempoccurencesforcreativesignature(occurrenceid,mediastream)
		  SELECT [OccurrenceDetailID],mediastream
		  FROM  [dbo].[vw_OccurrenceDetailAV]
		  --INNER JOIN [CreativeStaging] ON [dbo].[vw_OccurrenceDetailAV].creativesignature = [CreativeStaging].creativesignature 
		  WHERE  [vw_OccurrenceDetailAV].creativesignature = @creativesignature 
		  
		  
          SELECT @primaryOccurrenceID = Min(occurrenceid),@occurrencemediastream = mediastream 
          FROM   #tempoccurencesforcreativesignature 
		  group by occurrenceid,MediaStream

		  print @primaryOccurrenceID

		  -- Check if CreativeMaster Stg record exists     
		  IF EXISTS(SELECT 1 
                    FROM   [CreativeStaging] a 
                           --INNER JOIN [PatternStaging] b 
                           --        ON a.[CreativeStagingID] = b.[CreativeStgID] 
                    WHERE  a.CreativeSignature = @creativesignature
					) 
		  BEGIN 
                --- Inserting data Into CreativeMaster     
                INSERT INTO [Creative] ([AdId],[SourceOccurrenceId],checkinoccrncs,primaryindicator) 
                SELECT @adid,@primaryoccurrenceid,1,1 

           -- Retreiveing newly inserted CreativeMasterID     
                SELECT @creativemasterid = Scope_identity() 

			 ---Get CreativeStagingID from [CREATIVEMASTERSTAGING]   
			 IF @occurrencemediastream = 'TV'    
			 BEGIN
				SELECT @CreativeStagingID= a.[CreativeStagingID],@Patternmasterstgid=b.[PatternStagingID]   FROM   [CreativeStaging] a 
						  INNER JOIN [PatternStaging] b  ON a.[CreativeStagingID] = b.CreativeStgID 
						  WHERE  a.CreativeSignature = @creativesignature

						    --- Moving Data from CreativeDetailStagingONV to CreativeDetailONV     
				INSERT INTO CreativeDetailONV
						  (
							    [CreativeMasterID],
							    CreativeAssetName, 
						  CreativeRepository, 
						  LegacyAssetName, 
						  CreativeFileType,
							    CreativeFileSize,
							    [CreativeFileDT]
								) 
				SELECT @CreativeMasterID, 
					  MediaFileName, 
					  MediaFilepath, 
					  null, 
					  MediaFormat, 
					   FileSize,
					   GETDATE() 
				FROM   [CreativeDetailStagingTV]  WHERE [CreativeDetailStagingTV].MediaFormat='mpg' --Hard Coded Value,to be removed
				AND  [CreativeStgMasterID]= @CreativeStagingID 

			 END
			 ELSE IF @occurrencemediastream = 'ONV'
			 BEGIN
				SELECT @CreativeStagingID= a.[CreativeStagingID],@Patternmasterstgid=b.[PatternStagingID]   FROM   [CreativeStaging] a 
						  INNER JOIN [PatternStaging] b  ON a.[CreativeStagingID] = b.[CreativeStgID] 
						  WHERE  a.CreativeSignature = @creativesignature

						    --- Moving Data from CreativeDetailStagingONV to CreativeDetailONV     
				INSERT INTO CreativeDetailONV
						  (
							    [CreativeMasterID],
							    CreativeAssetName, 
						  CreativeRepository, 
						  LegacyAssetName, 
						  CreativeFileType,
							    CreativeFileSize,
							    [CreativeFileDT]
								) 
				SELECT	@creativemasterid,
						    [dbo].[CreativeDetailStagingONV].[SignatureDefault]+'.'+[dbo].[CreativeDetailStagingONV].CreativeFileType,
						    CreativeRepository, 
						    Null, 
					  CreativeFileType,
						  FileSize,
						  GETDATE() 
				FROM   CreativeDetailStagingONV
				WHERE  CreativeStagingID = @CreativeStagingID 
				    And CreativeFileType='MP4' and CreativeDownloaded=1 and FileSize>0  --Updated By Karunakar on 15th October 2015,adding Checks for filesize and filetype

			 END
			 ELSE IF @occurrencemediastream = 'CIN'
			 BEGIN
				SELECT @CreativeStagingID= a.[CreativeStagingID],@Patternmasterstgid=b.[PatternStagingID]   FROM   [CreativeStaging] a 
						  INNER JOIN [PatternStaging] b  ON a.[CreativeStagingID] = b.[CreativeStgID] 
						  WHERE  a.CreativeSignature = @creativesignature

				INSERT INTO CreativeDetailONV
				(
				    [CreativeMasterID],
				    CreativeAssetName, 
				    CreativeRepository, 
				    LegacyAssetName, 
				    CreativeFileType,
				    CreativeFileSize,
				    [CreativeFileDT]
				) 
				SELECT @CreativeMasterID, 
					[CreativeAssetName], 
					[CreativeRepository], 
					null, 
					[CreativeFileType],
					[CreativeFileSize],
				    GETDATE() 
				FROM   dbo.[CreativeDetailStagingCIN]
				WHERE  [CreativeStagingID]= @CreativeStagingID  
			 END
         
            END 
		
	   IF @occurrencemediastream = 'TV'    
	   BEGIN
		  INSERT INTO [Pattern] ([CreativeID], [AdID], MediaStream, [Exception],  [Query], Status, CreateBy,CreateDate,ModifiedBy,ModifyDate,CreativeSignature) 
		    SELECT @CreativeMasterID, @adid, @MediaStream, [Exception], [Query],  'Valid',@UserId,Getdate(),NULL,NULL,@CreativeSignature
			FROM  [dbo].PatternStaging
		    WHERE  [CreativeSignature] = @CreativeSignature
	   END
	   ELSE
	   BEGIN
          --- Inserting data into PatternMaster  from [PatternMasterStg]     
          INSERT INTO [Pattern] ([CreativeID],[AdID],mediastream,[Exception],[Query],status,createby,createdate,modifiedby,modifydate,creativesignature) 
		    SELECT @creativemasterid,@adid,@mediastream,[Exception],[Query],'Valid',@userid,Getdate(),NULL,NULL,@creativesignature FROM   [dbo].[PatternStaging]
			 WHERE [PatternStaging].[PatternStagingID]=@Patternmasterstgid 
	   END

        SET @patternmasterid=Scope_identity(); 

          ----Update PatternMasterID and Ad into OccurrenceDetailsONV for all occurrences of selected creative signature     
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
		  print 'TV'
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

		  
          -- Update Occurrenceid in Ad Table     
          UPDATE ad SET    [PrimaryOccurrenceID] = @primaryoccurrenceid WHERE  [AdID] = @adid AND [PrimaryOccurrenceID] IS NULL 

          -- Updating MOD Reason Into AD table     
         
			IF @Description<>''
			   BEGIN  
			   UPDATE Ad SET    description =description+','+ @Description  WHERE  [AdID] = @AdID
			   END 
			   IF @RecutDetail<>''
			   BEGIN  
			   UPDATE Ad SET    RecutDetail =recutdetail+','+@RecutDetail  WHERE  [AdID] = @AdID
			 END 

			 	

          COMMIT TRANSACTION 
      END TRY 

      BEGIN CATCH 
          DECLARE @error   INT,@message VARCHAR(4000),@lineno  INT 
          SELECT @error = Error_number(),@message = Error_message(),@lineno = Error_line() 
          RAISERROR ('[dbo].[sp_OnlineVideoMapCreativeSignatureToAd] : %d: %s',16,1,@error,@message,@lineno); 
          ROLLBACK TRANSACTION 
      END CATCH 
  END