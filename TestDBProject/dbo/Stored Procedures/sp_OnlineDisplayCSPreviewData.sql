
-- ====================================================================================================================================
-- Author		: Ramesh Bangi 
-- Create date  : 9/7/2015 
-- Description  : Fills the Data in Online Display Work Queue CreativeSignature Preview Details 
-- Execution	: [dbo].[sp_OnlineDisplayCSPreviewData] '192594ea9c51671fa4850ed1ab5fda5c620f6f85' 
-- Updated By	: Karunakar on 22nd Sep 2015,Joining Query Details  
--					Arun Nair on 11/24/2015 - Added AuditBy,AuditDTM Columns 
--				: Karunakar on 30th Nov 2015,Adding OccurrenceID into Selection and Removing OccurrenceID Parameter.
-- ====================================================================================================================================

CREATE PROCEDURE [dbo].[sp_OnlineDisplayCSPreviewData] (@CreativeSignature AS 

VARCHAR(max)) 

AS 

  BEGIN 

      SET nocount ON; 

      BEGIN try 

          DECLARE @MediastreamId AS varchar(3) 

          DECLARE @MinOccrnID AS BIGINT 


          SELECT @MinOccrnID = Min([OccurrenceDetailONDID]) 
          FROM   [OccurrenceDetailOND] 
          WHERE  creativesignature = @CreativeSignature 

          SELECT @MediastreamId = configurationid 
          FROM   [Configuration] 
          WHERE  componentname = 'Media Stream' 
		  AND value = 'OND' 



          SELECT TOP 1 [dbo].[scrapepage].[pageurl] AS WebsiteURL, 
                       [dbo].[landingpage].[landingurl]  AS  LandingPageURL, 
                       [dbo].[creativedetailstagingond].[landingpagedownloaded] AS LandingPageImageAvailableIndicator, 
                       '' AS Advertiser, 
                       [PatternStaging].mediaoutlet, 
                       [dbo].[creativedetailstagingond].[heightwidth] AS HeightByWidth, 
                       ''  AS  SuggestedAdId, 
                       [creativedetailstagingond].creativefiletype, 
                       [creativedetailstagingond].filesize AS CreativeFileSize, 
                       '' AS [Format], 
                       [dbo].[QueryDetail].[QueryText],
					   [dbo].[QueryDetail].[QryAnswer], 
                       dbo.[PatternStaging].[LanguageID], 
                       ( [dbo].[user].fname + ' ' + [dbo].[user].lname ) AS AuditBy, 
                       CONVERT(VARCHAR(30), [PatternStaging].[AuditedDT], 101) AS AuditDTM, 
                       @MinOccrnID  AS OccurrenceID 
          FROM   dbo.[PatternStaging] 
                 INNER JOIN dbo.[CreativeStaging] 
                 ON dbo.[PatternStaging].[CreativeStgID] = dbo.[CreativeStaging].[CreativeStagingID] 
                 INNER JOIN dbo.[OccurrenceDetailOND] 
                 ON dbo.[PatternStaging].[PatternStagingID] = dbo.[OccurrenceDetailOND].[PatternStagingID] 
                 INNER JOIN dbo.[creativedetailstagingond] 
                 ON dbo.[creativedetailstagingond].[CreativeStagingID] =[CreativeStaging].[CreativeStagingID] 
                 INNER JOIN dbo.[scrapepage]
                 ON dbo.[scrapepage].[ScrapePageID] = [OccurrenceDetailOND].[ScrapePageID] 
                 LEFT JOIN [QueryDetail] 
                 ON [dbo].[QueryDetail].[PatternStgID] = [PatternStaging].[PatternStagingID] 
                 LEFT JOIN dbo.[landingpage]
                 ON dbo.[OccurrenceDetailOND].[LandingPageID] = dbo.[landingpage].[LandingPageID] 
                 LEFT JOIN [dbo].[user]
				 ON [dbo].[user].userid = [PatternStaging].[AuditedByID] 
          WHERE  [OccurrenceDetailOND].creativesignature = @CreativeSignature 
                 AND dbo.creativedetailstagingond.creativedownloaded = 1 
                 AND dbo.creativedetailstagingond.filesize > 0 
                 AND dbo.creativedetailstagingond.creativefiletype = 'jpg' 
                 AND [PatternStaging].mediastream = @MediastreamId 
      END try 


      BEGIN catch 
          DECLARE @Error   INT, 
                  @Message VARCHAR(4000), 
                  @LineNo  INT 

          SELECT @Error = Error_number(), 
                 @Message = Error_message(), 
                 @LineNo = Error_line() 

          RAISERROR (' [dbo].[sp_OnlineDisplayCSPreviewData]: %d: %s',16,1, 

                     @error, 
                     @message,@lineNo); 

      END catch 

  END