





-- ================================================================
-- Author			: Arun Nair
-- Create date		: 21 September 2015
-- Description		: Search Online Display Ad Data   
-- Updated By		: Arun Nair on 09/28/2015 - Added Format 
-- ================================================================


CREATE VIEW [dbo].[vw_UniversalSearchOnlineDisplay]  
 with Schemabinding
As
SELECT AD.[AdID]                                   AS AdID, 
       AD.[OriginalAdID], 
       AD.[PrimaryOccurrenceID]                         AS OccurrenceID, 
       [Advertiser].Descrip                   AS Advertiser, 
	   [Advertiser].AdvertiserID			  AS AdvertiserID,
       CONVERT(VARCHAR, AD.LastRunDate, 101)      AS LastRunDate, 
       CONVERT(VARCHAR, AD.CreateDate, 101)     AS CreateDate, 
       AD.LeadAvHeadline                          AS LeadAudio, 
       AD.AdLength                                AS [Len], 
       AD.LeadText                                AS LeadText, 
       [Pattern].MediaStream                  AS MediaStreamID, 
       AD.RecutDetail                             AS RecutDetail, 
       [Language].description                 AS Language, 
       [OccurrenceDetailOND].CreativeSignature, 
       Ad.advisual                                AS Visual, 
       AD.taglineid,
	   AD.description							  AS [Description], 
       AD.[notakeadreason],
	   Ad.Unclassified ,
	   [Pattern].[PatternID],
	   'N/A' AS [Format]
FROM   dbo.AD 
INNER JOIN [dbo].[Language] ON AD.[LanguageID] = [Language].languageid 
INNER JOIN [dbo].[Advertiser] ON AD.[AdvertiserID] = [Advertiser].AdvertiserID 
INNER JOIN [dbo].[OccurrenceDetailOND] ON Ad.[PrimaryOccurrenceID]= dbo.[OccurrenceDetailOND].[OccurrenceDetailONDID]
INNER JOIN [dbo].[Pattern] ON AD.[AdID] = [Pattern].[AdID] AND dbo.[Pattern].[PatternID]=dbo.[OccurrenceDetailOND].[PatternID] 
INNER JOIN [dbo].[Creative] ON [Creative].[AdId] = AD.[AdID] AND [Creative].PrimaryIndicator = 1 
AND [Pattern].[CreativeID] = [Creative].PK_Id  
INNER JOIN [dbo].[Configuration] on [Configuration].configurationid=[Pattern].MediaStream 
AND [Configuration].systemname='All' AND [Configuration].componentname='Media Stream' and [Configuration].value='OND'
GO
CREATE UNIQUE CLUSTERED INDEX [IDX_vw_UniversalSearchOnlineDisplay]
    ON [dbo].[vw_UniversalSearchOnlineDisplay]([AdID] ASC);

