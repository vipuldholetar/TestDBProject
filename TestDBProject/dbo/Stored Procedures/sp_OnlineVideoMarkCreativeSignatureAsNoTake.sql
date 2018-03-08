
-- ========================================================================================================================================    
-- Author        : Karunakar     
-- Create date   : 09/28/2015     
-- Description   : Mark Creative Signature As No Take for Online Video    
-- Exec			 : sp_OnlineVideoMarkCreativeSignatureAsNoTake '',162   
-- Updated By	 :
--		Steps	 :1. Move records from Staging to Core tables     
--				  2. Update PatternMasterID and Ad into OccurrenceDetailsONV for all occurrences of selected creative signature     --               
--                3. Delete records from staging tables after successful movement 
--				: Karunakar on 15th October 2015,
--								1.Adding CreativeDownload and FileSize ,CreativeFileType Check in inserting Query
--								2.Replacing  CreativeAssestname with SignatureDefault and CreativeFileType 
-- =========================================================================================================================================      
CREATE PROCEDURE [dbo].[sp_OnlineVideoMarkCreativeSignatureAsNoTake] 
( 
@creativesignature NVARCHAR(max),
@notakereasonid INT,
@userid INT
) 
AS 
    IF 1 = 0 
      BEGIN 
          SET FMTONLY OFF 
      END 
  BEGIN 
      SET NOCOUNT ON; 

      DECLARE @primaryoccurrenceid AS BIGINT=0 
      DECLARE @creativemasterid AS INT=0 
      DECLARE @patternmasterid AS INT=0 
      DECLARE @CreativeStagingID AS INT=0 
      DECLARE @notakereason AS VARCHAR(100) 
      DECLARE @mediastreamid AS INT 
	  DECLARE @Patternmasterstgid as int=0

      BEGIN TRY 
          BEGIN TRANSACTION 

          -- Retrieving Media Stream ID     
          SELECT @mediastreamid = configurationid FROM   [dbo].[Configuration] WHERE  systemname = 'ALL' AND componentname = 'Media Stream' AND value = 'ONV' 

          -- Retrieving No Take Reason value title     
          SELECT @notakereason = valuetitle FROM   [Configuration] WHERE  configurationid = @notakereasonid 

          -- Retrieve Primary occurrence ID     
          SELECT @primaryoccurrenceid = Min([OccurrenceDetailONV].[OccurrenceDetailONVID]) 
          FROM   [dbo].[OccurrenceDetailONV] 
                 INNER JOIN [CreativeStaging] 
                         ON [OccurrenceDetailONV].CreativeSignature = 
                            [CreativeStaging].CreativeSignature 
          WHERE  [CreativeStaging].creativesignature = @creativesignature 

          --- Insert into CreativeMaster    
          INSERT INTO [Creative] ([AdId],[SourceOccurrenceId],checkinoccrncs) 
          SELECT NULL,@primaryoccurrenceid,1 

          SELECT @creativemasterid = Scope_identity() 

             ---Get CreativeStagingID from [CREATIVEMASTERSTAGING]       
               SELECT @CreativeStagingID= a.[CreativeStagingID],@Patternmasterstgid=b.[PatternStagingID]   FROM   [CreativeStaging] a 
			          INNER JOIN [PatternStaging] b  ON a.[CreativeStagingID] = b.[CreativeStgID] WHERE  a.CreativeSignature = @creativesignature

            --- Moving Data from CreativeDetailStagingONV to [CreativeDetailONV]
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

	  SELECT @PatternMasterID = p.Patternid FROM Pattern p inner join [PatternStaging] ps on p.PatternID=ps.PatternID
			 WHERE  ps.[CreativeStgID] = @CreativeStagingID

			 IF @PatternMasterID IS NULL OR @PatternMasterID = 0
			  BEGIN 

          -- Getting data from PatternMasterStg  and inserting data into PatternMaster      
          INSERT INTO [Pattern] ([CreativeID],[AdID],mediastream,[Exception],[Query],status,createby,createdate,notakereasoncode,creativesignature) 
          SELECT @creativemasterid,NULL,@mediastreamid,[Exception],[Query],'Valid',@userid,Getdate(),@notakereason,@creativesignature 
          FROM   [dbo].[PatternStaging] WHERE [PatternStaging].[PatternStagingID]=@Patternmasterstgid 

          SET @patternmasterid=Scope_identity(); 

		  	End
				ELSE
				 BEGIN

			 		UPDATE [Pattern]  
					SET [CreativeID]=@CreativeMasterID, [Pattern].[Exception]=[PatternStaging].[Exception],
						[Pattern].[Query]=[PatternStaging].[Query], [status]= 'Valid',
						ModifiedBy=@UserID, ModifyDate=Getdate(),[Priority]=5
					FROM [Pattern]  
					INNER JOIN [PatternStaging] on [Pattern].PatternID= [PatternStaging].PatternID
					where [Pattern].PatternID =@PatternMasterID

				 END

          ----Update PatternMasterID and Ad into OccurrenceDetailsONV for all occurrences of selected creative signature     
          UPDATE [dbo].[OccurrenceDetailONV] SET  [PatternID] = @patternmasterid,[PatternStagingID]=Null 
		  WHERE  [dbo].[OccurrenceDetailONV].CreativeSignature = @creativesignature 

          -- Deleting Staging records after successful movement to core tables     
             EXEC [sp_OnlineVideoDeleteStagingRecords]   @CreativeStagingID 
          COMMIT TRANSACTION 
      END TRY 

      BEGIN CATCH 
          DECLARE @error   INT,@message VARCHAR(4000),@lineno  INT 
          SELECT @error = Error_number(),@message = Error_message(),@lineno = Error_line() 
		  ROLLBACK TRANSACTION 
          RAISERROR ('[sp_OnlineVideoMarkCreativeSignatureAsNoTake]: %d: %s',16,1,@error,@message,@lineno); 
      END CATCH 
  END