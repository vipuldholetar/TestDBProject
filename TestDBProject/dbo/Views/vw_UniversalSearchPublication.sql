





-- =================================================================================
-- Author       : Arun Nair  
-- Create date  : 
-- Description  :
-- Updated By   : Arun Nair On 07/01/2015 - Change in Configuration value
--				  Arun Nair On 09/28/2015 - Added Format 
--====================================================================================

CREATE VIEW [dbo].[vw_UniversalSearchPublication]
WITH SCHEMABINDING
As

SELECT AD.[AdID]                                  AS AdID, 
       AD.[OriginalAdID], 
       AD.[PrimaryOccurrenceID]                   AS OccurrenceID, 
       [Advertiser].Descrip                 AS Advertiser, 
	   [Advertiser].AdvertiserID			AS AdvertiserID,
       CONVERT(VARCHAR, AD.LastRunDate, 101)  AS LastRunDate, 
       CONVERT(VARCHAR, AD.CreateDate, 101) AS CreateDate, 
       AD.LeadAvHeadline                     AS LeadAudio, 
       AD.AdLength                             AS [Len], 
       AD.LeadText                             AS LeadText, 
       [Pattern].mediastream                AS MediaStreamID, 
       AD.RecutDetail                          AS RecutDetail, 
       [Language].description               AS Language, 
       ''            AS CreativeSignature, 
       AdVisual                                AS Visual, 
       AD.taglineid, 
	   AD.description      AS [Description], 
       AD.[notakeadreason],
	   Ad.Unclassified ,
	    'N/A' AS [Format]
 FROM   dbo.AD 
        INNER JOIN dbo.[Language] ON AD.[LanguageID] = [Language].languageid 
	   INNER JOIN dbo.[Advertiser] ON AD.[AdvertiserID] = [Advertiser].advertiserID 
	   INNER JOIN [dbo].[OccurrenceDetailPUB] ON [dbo].[OccurrenceDetailPUB].[OccurrenceDetailPUBID]=AD.[PrimaryOccurrenceID] 
	   INNER JOIN dbo.[Pattern] ON  [dbo].[OccurrenceDetailPUB].[PatternID]=[Pattern].[PatternID]
	   INNER JOIN dbo.[Configuration] ON [Pattern].mediastream=[Configuration].Configurationid
				  AND dbo.[Configuration].systemname='All' and dbo.[Configuration].componentname='Media Stream' 
				  AND  dbo.[Configuration].value='PUB'
GO
CREATE UNIQUE CLUSTERED INDEX [IDX_vw_UniversalSearchPublication]
    ON [dbo].[vw_UniversalSearchPublication]([AdID] ASC);

