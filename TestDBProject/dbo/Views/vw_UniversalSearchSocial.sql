



-- ======================================================================
-- Author			: Arun Nair
-- Create date		: 11/20/2015
-- Description		: Get Social Ad Data
-- Updated By		: select * from [dbo].[vw_UniversalSearchSocial]
-- Updated By Lisa East 6.13.17	: Added MediaStream colum
-- ======================================================================
CREATE VIEW [dbo].[vw_UniversalSearchSocial]  
WITH SCHEMABINDING
AS
SELECT AD.[AdID]                                   AS AdID, 
       AD.[OriginalAdID], 
       AD.[PrimaryOccurrenceID]                         AS OccurrenceID, 
       [Advertiser].Descrip                   AS Advertiser, 
	   [Advertiser].AdvertiserID			  AS AdvertiserID,
	   AD.ProductId,
       CONVERT(VARCHAR, AD.LastRunDate, 101)      AS LastRunDate, 
       CONVERT(VARCHAR, AD.CreateDate, 101)     AS CreateDate, 
       AD.LeadAvHeadline                          AS LeadAudio, 
       AD.AdLength                                AS [Len], 
       AD.LeadText                                AS LeadText, 
       [Pattern].MediaStream                  AS MediaStreamID,
	   [Configuration].ValueTitle AS MediaStream, 
       AD.RecutDetail                             AS RecutDetail, 
       [Language].description                 AS Language,       
       Ad.advisual                                AS Visual, 
       AD.taglineid,
	   AD.description							  AS [Description], 
       AD.[notakeadreason],Ad.Unclassified ,[Pattern].[PatternID],'N/A' AS [Format],
	   [OccurrenceDetailSOC].SocialType,
	   Ad.Coop1AdvId,
	   Ad.Coop2AdvId,
	   Ad.Coop3AdvId,
	   Ad.Comp1AdvId,
	   Ad.Comp2AdvId
FROM   dbo.AD 
INNER JOIN [dbo].[Language] ON AD.[LanguageID] = [Language].languageid 
INNER JOIN [dbo].[Advertiser] ON AD.[AdvertiserID] = [Advertiser].AdvertiserID 
INNER JOIN [dbo].[OccurrenceDetailSOC] ON Ad.primaryoccurrenceid = [dbo].[OccurrenceDetailSOC].occurrencedetailsocid
INNER JOIN [dbo].[Pattern] ON AD.[AdID] = [Pattern].[AdID] AND dbo.[Pattern].[PatternID]=[dbo].[OccurrenceDetailSOC].[PatternID] 
INNER JOIN [dbo].[Configuration] on [Configuration].configurationid=[Pattern].MediaStream 
AND [Configuration].systemname='All' AND [Configuration].componentname='Media Stream' and [Configuration].value='SOC' --and [OccurrenceDetailSOC].SocialType='BRAND'
WHERE AD.Valid = 1
GO
CREATE UNIQUE CLUSTERED INDEX [IDX_vw_UniversalSearchSocial]
    ON [dbo].[vw_UniversalSearchSocial]([AdID] ASC);

