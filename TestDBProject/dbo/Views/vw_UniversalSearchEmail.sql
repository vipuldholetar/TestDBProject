









-- ======================================================================
-- Author			: Arun Nair
-- Create date		: 10/19/2015
-- Description		: Get Email Ad Data
-- Updated By		: 
-- ======================================================================
CREATE VIEW [dbo].[vw_UniversalSearchEmail]  
 with Schemabinding
As
SELECT AD.[AdID]                                   AS AdID, 
       AD.[OriginalAdID], 
       -- this won't work with the indexes we have on these views     --  (select min(OccurrenceDetailEMID) from dbo.[OccurrenceDetailEM] where [OccurrenceDetailEM].[PatternId] = [Pattern].[PatternId]) as OccurrenceId,
       null as OccurrenceId,
       [Advertiser].Descrip                   AS Advertiser, 
	   [Advertiser].AdvertiserID			  AS AdvertiserID,
	   AD.ProductId,
       CONVERT(VARCHAR, AD.LastRunDate, 101)      AS LastRunDate, 
       CONVERT(VARCHAR, AD.CreateDate, 101)     AS CreateDate, 
       AD.LeadAvHeadline                          AS LeadAudio, 
       AD.AdLength                                AS [Len], 
       AD.LeadText                                AS LeadText, 
	  [Configuration].ValueTitle AS MediaStream,
       [Pattern].MediaStream                  AS MediaStreamID, 
       AD.RecutDetail                             AS RecutDetail, 
       [Language].description                 AS Language,       
       Ad.advisual                                AS Visual, 
       AD.taglineid,
	   AD.description							  AS [Description], 
       AD.[notakeadreason],Ad.Unclassified ,[Pattern].[PatternID],'N/A' AS [Format],
	   Ad.Coop1AdvId,
	   Ad.Coop2AdvId,
	   Ad.Coop3AdvId,
	   Ad.Comp1AdvId,
	   Ad.Comp2AdvId

FROM   dbo.AD 
INNER JOIN [dbo].[Language] ON AD.[LanguageID] = [Language].languageid 
INNER JOIN [dbo].[Advertiser] ON AD.[AdvertiserID] = [Advertiser].AdvertiserID 
INNER JOIN [dbo].[Pattern] ON AD.[AdID] = [Pattern].[AdID]
INNER JOIN [dbo].[Creative] ON [Creative].[AdId] = AD.[AdID] AND [Creative].PrimaryIndicator = 1 AND [Pattern].[CreativeID] = [Creative].PK_Id  
INNER JOIN [dbo].[Configuration] on [Configuration].configurationid=[Pattern].MediaStream 
AND [Configuration].systemname='All' AND [Configuration].componentname='Media Stream' and [Configuration].value='EM'
WHERE AD.Valid = 1
GO
CREATE UNIQUE CLUSTERED INDEX [IDX_vw_UniversalSearchEmail]
    ON [dbo].[vw_UniversalSearchEmail]([PatternID] ASC);

