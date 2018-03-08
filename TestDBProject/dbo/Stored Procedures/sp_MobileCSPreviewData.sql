
-- ====================================================================================================================================
-- Author    : Ramesh Bangi 
-- Create date  : 9/30/2015 
-- Description  : Fills the Data in Mobile Work Queue CreativeSignature Preview Details  
-- Execution  : [dbo].[sp_MobileCSPreviewData] '000542110e2dd815d1ebecc109abc906340ce7db' 
-- Updated By  : Karunakar on 20th Oct 2015,Removing Creative File Type Check in CreativeDetailStagingMOB
--          Arun Nair on 11/24/2015 - Added AuditBy,AuditDTM Columns 
--        : Karunakar on 30th Nov 2015,Adding OccurrenceID into Selection and Removing OccurrenceID Parameter.
-- ====================================================================================================================================
CREATE PROCEDURE [dbo].[sp_MobileCSPreviewData] (@CreativeSignature AS VARCHAR(max)) 
AS 
  BEGIN 
      SET nocount ON; 

      BEGIN try 
          DECLARE @MediastreamId INT 
          DECLARE @MinOccrnID AS BIGINT 

          SELECT @MinOccrnID = Min([OccurrenceDetailMOBID]) 
          FROM   [OccurrenceDetailMOB] 
          WHERE  creativesignature = @CreativeSignature 

          SELECT @MediastreamId = configurationid 
          FROM   [Configuration] 
          WHERE  componentname = 'Media Stream' 
                 AND value = 'MOB' 

          SELECT TOP 1 '' AS Advertiser, 
                       [dbo].[landingpage].[landingurl] AS LandingPageURL, 
                       [dbo].[creativedetailstagingmob].[landingpagedownloaded] AS LandingPageImageAvailableIndicator, 
                       mobiledevice.NAME AS Device, 
                       [creativedetailstagingmob].creativefiletype AS CreativeFileType, 
                       [creativedetailstagingmob].filesize AS CreativeFileSize, 
                       ''AS Market, 
                       [LanguageID] AS LanguageId, 
                       [dbo].[QueryDetail].QueryText,
                       [dbo].[QueryDetail].[QryAnswer], 
                       ( [dbo].[user].fname + ' ' + [dbo].[user].lname ) AS AuditBy, 
                       CONVERT(VARCHAR(30), [PatternStaging].[AuditedDT], 101) AS AuditDTM, 
                       @MinOccrnID AS OccurrenceID 
          FROM   dbo.[PatternStaging] 
                 INNER JOIN dbo.[CreativeStaging] 
                 ON dbo.[PatternStaging].[CreativeStgID] = dbo.[CreativeStaging].[CreativeStagingID] 
                 INNER JOIN dbo.[OccurrenceDetailMOB] 
                 ON dbo.[PatternStaging].[PatternStagingID] = dbo.[OccurrenceDetailMOB].[PatternStagingID] 
                 LEFT JOIN dbo.[mobilecapturesession] 
                 ON [OccurrenceDetailMOB].[CaptureSessionID] =mobilecapturesession.[MobileCaptureSessionID] 
                 LEFT JOIN dbo.[mobilejobschedule] 
                 ON mobilecapturesession.[MobileJobScheduleID] = mobilejobschedule.[MobileJobScheduleID] 
                 LEFT JOIN dbo.[mobiledevice] 
                 ON mobilejobschedule.[MobileDeviceID] = mobiledevice.[MobileDeviceID] 
                 LEFT JOIN [QueryDetail] 
                 ON [dbo].[QueryDetail].[PatternStgID] =[PatternStaging].[PatternStagingID] 
                 INNER JOIN dbo.[creativedetailstagingmob] 
                 ON dbo.[creativedetailstagingmob].[CreativeStagingID] = [CreativeStaging].[CreativeStagingID] 
                 LEFT JOIN dbo.[landingpage] 
                 ON dbo.[OccurrenceDetailMOB].[LandingPageID] =dbo.[landingpage].[LandingPageID] 
                 LEFT JOIN [dbo].[user] 
                 ON [dbo].[user].userid = [PatternStaging].[AuditedByID] 
          WHERE  [OccurrenceDetailMOB].creativesignature = @CreativeSignature 
                 AND dbo.[creativedetailstagingmob].creativedownloaded = 1 
                 AND dbo.[creativedetailstagingmob].filesize > 0 
                 AND [PatternStaging].mediastream = @MediastreamId 
      END try 

      BEGIN catch 
          DECLARE @Error   INT, 
                  @Message VARCHAR(4000), 
                  @LineNo  INT 

          SELECT @Error = Error_number(), 
                 @Message = Error_message(), 
                 @LineNo = Error_line() 

          RAISERROR (' [dbo].[sp_MobileCSPreviewData]: %d: %s',16,1,@error, 
                     @message, 
                     @lineNo); 
      END catch 
  END