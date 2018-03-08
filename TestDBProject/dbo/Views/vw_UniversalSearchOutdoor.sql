











-- ================================================================
-- Author			: KARUNAKAR 
-- Create date		: 6th jULY 2015
-- Description		: Search Outdoor Ad Data   
-- Updated By		: Ramesh On 08/12/2015  - CleanUp for OneMTDB 
--					  Arun Nair on 09/28/2015 - Added Format 
-- ================================================================


CREATE VIEW [dbo].[vw_UniversalSearchOutdoor]  
 with Schemabinding
As
SELECT AD.[AdID]                                  AS AdID, 
       AD.[OriginalAdID], 
       -- this won't work with current indexes we have on this view  --(select min([OccurrenceDetailODRID]) from dbo.[OccurrenceDetailODR] where [OccurrenceDetailODR].[PatternId] = [Pattern].[PatternId]) as OccurrenceId,
	   null as OccurrenceId,
       [Advertiser].Descrip                 AS Advertiser, 
	   [Advertiser].AdvertiserID			AS AdvertiserID,
	   AD.ProductId,
       CONVERT(VARCHAR, AD.LastRunDate, 101)  AS LastRunDate, 
       CONVERT(VARCHAR, AD.CreateDate, 101) AS CreateDate, 
       AD.LeadAvHeadline                     AS LeadAudio, 
       AD.AdLength                             AS [Len], 
       AD.LeadText                             AS LeadText, 
	  --[Configuration].ValueTitle AS MediaStream,
	  'Outdoor' as MediaStream,
       --[Pattern].MediaStream                AS MediaStreamID, 
	   149 as MediaStreamID,
       AD.RecutDetail                          AS RecutDetail, 
       [Language].description               AS Language, 
       cast([Creative].PK_ID as varchar)      AS CreativeSignature, 
       Ad.advisual                                AS Visual, 
       AD.taglineid, 
	   AD.description      AS [Description], 
       AD.[notakeadreason],
	   Ad.Unclassified ,
	   --[Pattern].[PatternID]
	   0 PatternID,
	   [ODRAdFormatMap].[FormatDescrip] as [Format],
	   Ad.Coop1AdvId,
	   Ad.Coop2AdvId,
	   Ad.Coop3AdvId,
	   Ad.Comp1AdvId,
	   Ad.Comp2AdvId
FROM   dbo.AD 
INNER JOIN dbo.[Language] ON AD.[LanguageID] = [Language].languageid 
INNER JOIN dbo.[Advertiser] ON AD.[AdvertiserID] = [Advertiser].advertiserID 
--INNER JOIN dbo.[Pattern] ON AD.[AdID] = [Pattern].[AdID] 
INNER JOIN dbo.[Creative] ON [Creative].[AdId] = AD.[AdID] 
		    AND [Creative].PrimaryIndicator = 1 
			--AND [Pattern].[CreativeID] = [Creative].PK_Id  
INNER JOIN dbo.[CreativeDetailODR] on CreativeMasterId = PK_ID
INNER JOIN dbo.[ODRAdFormatMap] on MTFormatID = AdFormatId
--INNER  JOIN dbo.[Configuration] ON [Configuration].configurationid=[Pattern].MediaStream
--			AND  [Configuration].systemname='All' and [Configuration].componentname='Media Stream' 
--			AND  [Configuration].value='OD'
WHERE AD.Valid = 1
GO
CREATE UNIQUE CLUSTERED INDEX [IDX_vw_UniversalSearchOutdoor]
    ON [dbo].[vw_UniversalSearchOutdoor]([AdID] ASC);

