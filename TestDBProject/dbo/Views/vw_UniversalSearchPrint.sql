﻿










CREATE VIEW [dbo].[vw_UniversalSearchPrint]
with schemabinding  
As

SELECT AD.[AdID]                                  AS AdID, 
       AD.[OriginalAdID], 
       AD.[PrimaryOccurrenceID]						AS OccurrenceID, 
       [Advertiser].Descrip                 AS Advertiser, 
	   [Advertiser].AdvertiserID			AS AdvertiserID,
       AD.LastRunDate, 
       AD.CreateDate, 
       AD.LeadAvHeadline                     AS LeadAudio, 
       AD.adlength                             AS [Len], 
       AD.leadtext                             AS LeadText, 
       [Pattern].mediastream                AS MediaStreamID, 
	  [Configuration].ValueTitle AS MediaStream,
       AD.recutdetail                          AS RecutDetail, 
       [Language].description               AS Language, 
	  AD.ProductId,
       advisual                                AS Visual, 
       AD.taglineid, 
	   AD.description      AS [Description], 
       AD.[notakeadreason],
	   Ad.Unclassified,
	   Ad.Coop1AdvId,
	   Ad.Coop2AdvId,
	   Ad.Coop3AdvId,
	   Ad.Comp1AdvId,
	   Ad.Comp2AdvId,
	   COUNT_BIG(*) AS COUNT
 FROM   dbo.AD 
INNER JOIN [dbo].[Language] ON AD.[LanguageID] = [Language].languageid 
INNER JOIN [dbo].[Advertiser] ON AD.[AdvertiserID] = [Advertiser].AdvertiserID 
INNER JOIN [dbo].[Creative] ON [Creative].[AdId] = AD.[AdID] AND [Creative].PrimaryIndicator = 1 
INNER JOIN [dbo].[Pattern] ON AD.[AdID] = [Pattern].[AdID] AND [Pattern].[CreativeID] = [Creative].PK_Id  
INNER JOIN [dbo].[Configuration] on [Configuration].configurationid=[Pattern].MediaStream 
AND [Configuration].systemname='All' AND [Configuration].componentname='Media Stream' 
and [Configuration].value in('CIR','PUB','DM') AND [PrimaryOccurrenceID] IS NOT NULL
WHERE AD.Valid = 1
GROUP BY AD.[AdID], AD.[OriginalAdID], AD.[PrimaryOccurrenceID], [Advertiser].Descrip, 
[Advertiser].AdvertiserID,AD.LastRunDate, 
AD.CreateDate, AD.LeadAvHeadline, AD.AdLength, AD.LeadText, 
[Pattern].MediaStream, [Configuration].ValueTitle,AD.RecutDetail, [Language].description, 
Ad.advisual, AD.taglineid,AD.description, AD.[notakeadreason],Ad.Unclassified,AD.ProductId,
Ad.Coop1AdvId,Ad.Coop2AdvId,Ad.Coop3AdvId,Ad.Comp1AdvId,Ad.Comp2AdvId
GO
CREATE UNIQUE CLUSTERED INDEX [IDX_vw_UniversalSearchPrint]
    ON [dbo].[vw_UniversalSearchPrint]([AdID] ASC);

