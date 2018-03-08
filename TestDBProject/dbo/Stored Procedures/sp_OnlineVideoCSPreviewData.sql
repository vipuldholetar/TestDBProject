
-- ====================================================================================================================================
-- Author    : Ramesh Bangi 
-- Create date  : 9/18/2015 
-- Description  : Fills the Data in Online Video Work Queue CreativeSignature Preview Details 
-- Execution  : [dbo].[sp_OnlineVideoCSPreviewData] 411860,'00d05154dbcf5213ca032ada4532393e515e5d94' 
-- Updated By  : Arun Nair on 11/24/2015 - Added AuditBy,AuditDTM Columns 
--        : Karunakar on 30th Nov 2015,Adding OccurrenceID into Selection and Removing OccurrenceID Parameter.
-- ====================================================================================================================================
CREATE PROCEDURE [dbo].[sp_OnlineVideoCSPreviewData] (@CreativeSignature AS 
VARCHAR(max)) 
AS 
  BEGIN 
      SET nocount ON; 

      BEGIN try 
          DECLARE @MediastreamId AS INT 
          DECLARE @MinOccrnID AS BIGINT 

          SELECT @MinOccrnID = Min([OccurrenceDetailONVID]) 
          FROM   [OccurrenceDetailONV] 
          WHERE  creativesignature = @CreativeSignature 

          SELECT @MediastreamId = configurationid 
          FROM   [Configuration] 
          WHERE  componentname = 'Media Stream' 
                 AND value = 'ONV' 

          SELECT TOP 1 '' 
                       AS 
                       WebsiteURL, 
                       [dbo].[landingpage].[landingurl] 
                       AS 
                       LandingPageURL, 
                       [dbo].[creativedetailstagingonv].[landingpagedownloaded] 
                       AS 
                       LandingPageImageAvailableIndicator, 
                       '' 
                       AS 
                       Advertiser, 
                       '' 
                       AS 
                       Market, 
                       [LanguageID] 
                       AS 
                       LanguageId, 
                       [creativedetailstagingonv].creativefiletype 
                       AS 
                       creativefiletype, 
                       [creativedetailstagingonv].filesize 
                       AS 
                       CreativeFileSize, 
                       '' 
                       AS 
                       SuggestedMC, 
                       ( [dbo].[QueryDetail].querytext ) + ' | ' + 
                       CONVERT(VARCHAR(max), [dbo].[QueryDetail].[QryAnswer]) 
                       AS 
                       QAndA, 
                       ( [dbo].[user].fname + ' ' + [dbo].[user].lname ) 
                       AS 
                       AuditBy 
                       , 
                       CONVERT(VARCHAR(30), [PatternStaging].[AuditedDT], 101) 
                       AS AuditDTM, 
                       @MinOccrnID 
                       AS 
                       OccurrenceID 
          FROM   dbo.[PatternStaging] 
                 INNER JOIN dbo.[CreativeStaging] 
                         ON dbo.[PatternStaging].[CreativeStgID] = 
                            dbo.[CreativeStaging].[CreativeStagingID] 
                 INNER JOIN dbo.[OccurrenceDetailONV] 
                         ON dbo.[PatternStaging].[PatternStagingID] = 
                 dbo.[OccurrenceDetailONV].[PatternStagingID] 
                 INNER JOIN dbo.[creativedetailstagingonv] 
                         ON 
                 dbo.[creativedetailstagingonv].[CreativeStagingID] = 
                 [CreativeStaging].[CreativeStagingID] 
                 INNER JOIN dbo.[scrapepage] 
                         ON dbo.[scrapepage].[ScrapePageID] = 
                            [OccurrenceDetailONV].[ScrapePageID] 
                 LEFT JOIN [QueryDetail] 
                        ON [dbo].[QueryDetail].[PatternStgID] = 
                           [PatternStaging].[PatternStagingID] 
                 LEFT JOIN dbo.[landingpage] 
                        ON dbo.[OccurrenceDetailONV].[LandingPageID] = 
                           dbo.[landingpage].[LandingPageID] 
                 LEFT JOIN [dbo].[user] 
                        ON [dbo].[user].userid = [PatternStaging].[AuditedByID] 
          WHERE  [OccurrenceDetailONV].creativesignature = @CreativeSignature 
                 AND dbo.creativedetailstagingonv.creativedownloaded = 1 
                 AND dbo.creativedetailstagingonv.filesize > 0 
                 AND dbo.creativedetailstagingonv.creativefiletype = 'mp4' 
                 AND [PatternStaging].mediastream = @MediastreamId 
      END try 

      BEGIN catch 
          DECLARE @Error   INT, 
                  @Message VARCHAR(4000), 
                  @LineNo  INT 

          SELECT @Error = Error_number(), 
                 @Message = Error_message(), 
                 @LineNo = Error_line() 

          RAISERROR (' [dbo].[sp_OnlineVideoCSPreviewData]: %d: %s',16,1,@error, 
                     @message,@lineNo); 
      END catch 
  END