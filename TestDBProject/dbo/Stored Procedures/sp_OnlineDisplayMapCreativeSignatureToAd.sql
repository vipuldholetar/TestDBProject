


-- =================================================================================================================      
-- Author		 : Arun Nair     
-- Create date   : 09/21/2015
-- Description   : This Procedure is Used to Mapping  on Ad to CreativeSignature for OnlineDisplay     
-- Updated By    :
	-- Steps	 :1. Move records from Staging to Core tables     
	--            2. Update PatternMasterID and Ad into OccurrenceDetailsCIN] for all occurrences of selected creative signature     
	--            2. Update Ad table with MTO reason     
	--            3. Delete records from staging tables after successful movement    
--				   Arun Nair on 10/12/2015 - Append Description with MODReason   
-- ================================================================================================================      
CREATE PROCEDURE [dbo].[sp_OnlineDisplayMapCreativeSignatureToAd] --5261,'bf72cc41d726d2708286f14260483d677467cb53',NULL,29712040
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
		  DECLARE @primaryoccurrenceid AS BIGINT 
		  DECLARE @Patternmasterstgid as int=0
		  DECLARE @occurrencemediastream AS VARCHAR(50)

          -- Get Mediastream from configuration master     
          SELECT @mediastream = configurationid FROM   [Configuration] WHERE  systemname = 'ALL' AND componentname = 'Media Stream' AND value = 'OND' 

          --Get MTO Reason from configuration master      
          
          -- Retrieve Primary occurrence ID     
    --      SELECT @primaryoccurrenceid = Min([dbo].[OccurrenceDetailOND].[OccurrenceDetailONDID]) 
		  --FROM  [dbo].[OccurrenceDetailOND]
		  --INNER JOIN [CreativeStaging] ON [dbo].[OccurrenceDetailOND].creativesignature = [CreativeStaging].creativesignature 
		  --WHERE  [CreativeStaging].creativesignature = @creativesignature 

		  SELECT @primaryoccurrenceid = Min([dbo].[vw_OccurrenceDetailDigital].[OccurrenceDetailID]), @occurrencemediastream = [vw_OccurrenceDetailDigital].mediastream
		  FROM  [dbo].[vw_OccurrenceDetailDigital]
		  INNER JOIN [CreativeStaging] ON [dbo].[vw_OccurrenceDetailDigital].creativesignature = [CreativeStaging].creativesignature 
		  WHERE  [vw_OccurrenceDetailDigital].creativesignature = @creativesignature 
		  group by [OccurrenceDetailID],mediastream
          -- Check if CreativeMaster Stg record exists     
          IF EXISTS(SELECT 1 
                    FROM   [CreativeStaging] a 
                           INNER JOIN [PatternStaging] b 
                                   ON a.[CreativeStagingID] = b.[CreativeStgID] 
                    WHERE  a.CreativeSignature = @creativesignature
					) 
            BEGIN 
                --- Inserting data Into CreativeMaster     
                INSERT INTO [Creative] ([AdId],[SourceOccurrenceId],checkinoccrncs,primaryindicator) 
                SELECT @adid,@primaryoccurrenceid,1,1 

           -- Retreiveing newly inserted CreativeMasterID     
                SELECT @creativemasterid = Scope_identity() 

           ---Get CreativeStagingID from [CREATIVEMASTERSTAGING]       
               SELECT @CreativeStagingID= a.[CreativeStagingID],@Patternmasterstgid=b.[PatternStagingID]   FROM   [CreativeStaging] a 
			          INNER JOIN [PatternStaging] b  ON a.[CreativeStagingID] = b.[CreativeStgID] WHERE  a.CreativeSignature = @creativesignature

				--print (@CreativeStagingID)
				--print (@Patternmasterstgid)

          --- Moving Data from CreativeDetailStagingOND to [CreativeDetailOND]  
			 IF @occurrencemediastream = 'OND'
			 BEGIN    
				INSERT INTO creativedetailond ([CreativeMasterID],CreativeAssetName,CreativeRepository,LegacyAssetName,CreativeFileType,CreativeFileSize,[CreativeFileDT])
				    SELECT	@creativemasterid,
				    [dbo].[CreativeDetailStagingOND].[SignatureDefault]+'.'+[dbo].[CreativeDetailStagingOND].CreativeFileType,
				    CreativeRepository,Null,CreativeFileType,FileSize,GETDATE() 
				FROM   CreativeDetailStagingOND
				WHERE  CreativeStagingID = @CreativeStagingID 
				    And CreativeFileType='JPG' and CreativeDownloaded=1 and FileSize>0 
			 END
			 ELSE IF @occurrencemediastream = 'MOB'
			 BEGIN
				INSERT INTO creativedetailond ([CreativeMasterID],CreativeAssetName,CreativeRepository,LegacyAssetName,CreativeFileType,CreativeFileSize,[CreativeFileDT])
				SELECT TOP 1 @creativemasterid,[dbo].[CreativeDetailStagingMOB].[SignatureDefault]+'.'+[dbo].[CreativeDetailStagingMOB].CreativeFileType, 
						    CreativeRepository, 
						    Null, 
					  CreativeFileType,
						  FileSize,
						  GETDATE() 
				FROM   [dbo].[CreativeDetailStagingMOB]
				WHERE  CreativeStagingID = @CreativeStagingID 
				   and CreativeDownloaded=1 and FileSize>0 
				    ORDER BY CreativeDetailStagingID
			 END
            END 
			SELECT @PatternMasterID=PatternID FROM [dbo].[PatternStaging] WHERE  CreativeStgID = @CreativeStagingID
			--L.E. on 1/31/2017
			IF EXISTS (SELECT TOP 1 * FROM PATTERN WHERE PATTERNID=@PatternMasterID)
			BEGIN 
				UPDATE [Pattern]  
				SET [CreativeID]=@CreativeMasterID, MediaStream=@MediaStream, [Pattern].[Exception]=[PatternStaging].[Exception],
					[Pattern].[Query]=[PatternStaging].[Query], [status]= 'Valid', 
					ModifiedBy=@UserID, ModifyDate=Getdate(),LastMappedDate=Getdate(),LastMapperInits=@userid
				FROM [Pattern]  
				INNER JOIN [PatternStaging] on [Pattern].PatternID= [PatternStaging].PatternID
				where [Pattern].PatternID =@PatternMasterID
			END 
			ELSE 
			BEGIN 
			
          --- Inserting data into PatternMaster  from [PatternMasterStg]     
          INSERT INTO [Pattern] ([CreativeID],[AdID],mediastream,[Exception],[Query],status,createby,createdate,modifiedby,modifydate,creativesignature) 
          SELECT @creativemasterid,@adid,@mediastream,[Exception],[Query],'Valid',@userid,Getdate(),NULL,NULL,@creativesignature FROM   [dbo].[PatternStaging]
		  WHERE [PatternStaging].[PatternStagingID]=@Patternmasterstgid 

          SET @patternmasterid=Scope_identity(); 
		  End

          ----Update PatternMasterID and Ad into OccurrenceDetailsCIN] for all occurrences of selected creative signature     
		  IF @occurrencemediastream = 'OND'
		  BEGIN  
			    UPDATE [dbo].[OccurrenceDetailOND] SET  [PatternID] = @patternmasterid,[AdID] = @adid,[PatternStagingID]=Null  
				WHERE  [dbo].[OccurrenceDetailOND].CreativeSignature = @creativesignature 
				
		    -- Deleting Staging records after successful movement to core tables     
			   EXEC [sp_OnlineDisplayDeleteStagingRecords]   @CreativeStagingID  
		  END
		  ELSE IF @occurrencemediastream = 'MOB'
		  BEGIN
			 ----Update PatternMasterID and Ad into OccurrenceDetailsCIN] for all occurrences of selected creative signature     
			   UPDATE [dbo].[OccurrenceDetailMOB] SET  [PatternID] = @patternmasterid,[AdID] = @adid,[PatternStagingID]=Null  
				WHERE  [dbo].[OccurrenceDetailMOB].CreativeSignature = @creativesignature 
				
		    -- Deleting Staging records after successful movement to core tables     
			   EXEC [dbo].[sp_MobileDeleteStagingRecords]  @CreativeStagingID  
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

			
			--print @CreativeStagingID
          COMMIT TRANSACTION 
      END TRY 

      BEGIN CATCH 
          DECLARE @error   INT,@message VARCHAR(4000),@lineno  INT 
          SELECT @error = Error_number(),@message = Error_message(),@lineno = Error_line() 
          RAISERROR ('[dbo].[sp_OnlineDisplayMapCreativeSignatureToAd] : %d: %s',16,1,@error,@message,@lineno); 
          ROLLBACK TRANSACTION 
      END CATCH 
  END