

-- ========================================================================================================================================    
-- Author        : Arun Nair     
-- Create date   : 09/22/2015     
-- Description   : Mark Creative Signature As No Take for Online     
-- Exec			 : sp_CinemaMarkCreativeSignatureasNoTake '335919aeg',162   
-- Updated By	 :
--		Steps	 :1. Move records from Staging to Core tables     
--				  2. Update PatternMasterID and Ad into OccurrenceDetailsOND] for all occurrences of selected creative signature     --               
--                3. Delete records from staging tables after successful movement 
-- =========================================================================================================================================      
CREATE PROCEDURE [dbo].[sp_OnlineDisplayMarkCreativeSignatureAsNoTake] 
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
          SELECT @mediastreamid = configurationid FROM   [dbo].[Configuration] WHERE  systemname = 'ALL' AND componentname = 'Media Stream' AND value = 'OND' 

          -- Retrieving No Take Reason value title     
          SELECT @notakereason = valuetitle FROM   [Configuration] WHERE  configurationid = @notakereasonid 

          -- Retrieve Primary occurrence ID     
          SELECT @primaryoccurrenceid = Min([dbo].[OccurrenceDetailOND].[OccurrenceDetailONDID]) FROM   [dbo].[OccurrenceDetailOND] 
		   INNER JOIN [CreativeStaging] ON [dbo].[OccurrenceDetailOND].CreativeSignature = [CreativeStaging].CreativeSignature
		    WHERE  [CreativeStaging].creativesignature = @creativesignature 

          --- Insert into CreativeMaster    
          INSERT INTO [Creative] ([AdId],[SourceOccurrenceId],checkinoccrncs) 
          SELECT NULL,@primaryoccurrenceid,1 

          SELECT @creativemasterid = Scope_identity() 

             ---Get CreativeStagingID from [CREATIVEMASTERSTAGING]       
               SELECT @CreativeStagingID= a.[CreativeStagingID],@Patternmasterstgid=b.[PatternStagingID]   FROM   [CreativeStaging] a 
			          INNER JOIN [PatternStaging] b  ON a.[CreativeStagingID] = b.[CreativeStgID] WHERE  a.CreativeSignature = @creativesignature

            --- Moving Data from CreativeDetailStagingOND to [CreativeDetailOND]      
                 INSERT INTO creativedetailond ([CreativeMasterID],CreativeAssetName,CreativeRepository,LegacyAssetName,CreativeFileType,CreativeFileSize,[CreativeFileDT])
				SELECT	@creativemasterid,
				[dbo].[CreativeDetailStagingOND].[SignatureDefault]+'.'+[dbo].[CreativeDetailStagingOND].CreativeFileType,
				CreativeRepository,Null,CreativeFileType,FileSize,GETDATE() FROM   CreativeDetailStagingOND
                WHERE  CreativeStagingID = @CreativeStagingID 
				And CreativeFileType='JPG' and CreativeDownloaded=1 and FileSize>0 

         SELECT @PatternMasterID = p.Patternid FROM Pattern p inner join [PatternStaging] ps on p.PatternID=ps.PatternID
			 WHERE  ps.[CreativeStgID] = @CreativeStagingID

			 IF @PatternMasterID IS NULL OR @PatternMasterID = 0
			  BEGIN

				  -- Getting data from PatternMasterStg  and inserting data into PatternMaster      
				  INSERT INTO [Pattern] ([CreativeID],[AdID],mediastream,[Exception],[Query],status,createby,createdate,notakereasoncode,creativesignature,[Priority]) 
				  SELECT @creativemasterid,NULL,@mediastreamid,[Exception],[Query],'Valid',@userid,Getdate(),@notakereason,@creativesignature,[Priority]
				  FROM   [dbo].[PatternStaging] WHERE [PatternStaging].[PatternStagingID]=@Patternmasterstgid 

				  SET @patternmasterid=Scope_identity(); 
				   END
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



          ----Update PatternMasterID and Ad into OccurrenceDetailsOND] for all occurrences of selected creative signature     
          UPDATE [dbo].[OccurrenceDetailOND] SET  [PatternID] = @patternmasterid,[PatternStagingID]=Null 
		   WHERE  [dbo].[OccurrenceDetailOND].CreativeSignature = @creativesignature 

          -- Deleting Staging records after successful movement to core tables     
             EXEC [sp_OnlineDisplayDeleteStagingRecords]   @CreativeStagingID 
          COMMIT TRANSACTION 
      END TRY 

      BEGIN CATCH 
          DECLARE @error   INT,@message VARCHAR(4000),@lineno  INT 
          SELECT @error = Error_number(),@message = Error_message(),@lineno = Error_line() 
		  ROLLBACK TRANSACTION 
          RAISERROR ('[sp_OnlineDisplayMarkCreativeSignatureAsNoTake]: %d: %s',16,1,@error,@message,@lineno); 
      END CATCH 
  END