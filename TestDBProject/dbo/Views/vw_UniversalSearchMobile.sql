

-- ================================================================
-- Author			: Arun Nair
-- Create date		: 10/05/2015
-- Description		: Search Mobile Ad Data 
-- Updated By		: 
-- ================================================================
CREATE VIEW [dbo].[vw_UniversalSearchMobile]  
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
       [dbo].[OccurrenceDetailMOB].CreativeSignature, 
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
INNER JOIN [dbo].[OccurrenceDetailMOB] ON Ad.[PrimaryOccurrenceID]= [dbo].[OccurrenceDetailMOB].[OccurrenceDetailMOBID]
INNER JOIN [dbo].[Pattern] ON AD.[AdID] = [Pattern].[AdID] AND dbo.[Pattern].[PatternID]=[dbo].[OccurrenceDetailMOB].[PatternID] 
INNER JOIN [dbo].[Creative] ON [Creative].[AdId] = AD.[AdID] AND [Creative].PrimaryIndicator = 1 
AND [Pattern].[CreativeID] = [Creative].PK_Id  
INNER JOIN [dbo].[Configuration] on [Configuration].configurationid=[Pattern].MediaStream 
AND [Configuration].systemname='All' AND [Configuration].componentname='Media Stream' and [Configuration].value='MOB'
GO
CREATE UNIQUE CLUSTERED INDEX [IDX_vw_UniversalSearchMobile]
    ON [dbo].[vw_UniversalSearchMobile]([AdID] ASC);

