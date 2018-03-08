





-- ========================================================================
-- Author			: KARUNAKAR 
-- Create date		: 6th jULY 2015
-- Description		: Search Cinema Ad Data
-- Updated By		: Ramesh On 08/12/2015  - CleanUp for OneMTDB    
--					  Arun Nair On 09/28/2015 - Added Format select * from [vw_UniversalSearchCinema]
--=========================================================================
CREATE VIEW [dbo].[vw_UniversalSearchCinema]
 with schemabinding        
As

SELECT Ad.[AdID]									AS AdID, 
       Ad.[OriginalAdID], 
       Ad.[PrimaryOccurrenceID]						AS OccurrenceID, 
       [Advertiser].Descrip					AS Advertiser, 
	   [Advertiser].AdvertiserID			AS AdvertiserID,
       CONVERT(VARCHAR, Ad.LastRunDate, 101)	AS LastRunDate, 
       CONVERT(VARCHAR, Ad.CreateDate, 101)	AS CreateDate, 
       Ad.LeadAvHeadline						AS LeadAudio, 
       Ad.AdLength								AS [Len], 
       Ad.LeadText								AS LeadText, 
       [Pattern].MediaStream				AS MediaStreamID, 
       Ad.RecutDetail							AS RecutDetail, 
       [Language].description				AS Language, 
      dbo.[OccurrenceDetailCIN].[CreativeID]     AS CreativeSignature, 
       Ad.AdVisual								AS Visual, 
       Ad.TaglineId, 
	   Ad.description				AS [Description], 
       Ad.NoTakeAdReason,
	   Ad.Unclassified ,
	   [Pattern].[PatternID],
	   'N/A' AS [Format]
FROM   dbo.Ad 
       INNER JOIN dbo.[Language] ON Ad.[LanguageID] = [Language].languageid 
		INNER JOIN dbo.[Advertiser] ON Ad.[AdvertiserID] = [Advertiser].advertiserID 
	   INNER JOIN dbo.[OccurrenceDetailCIN]
	            on Ad.[PrimaryOccurrenceID]= dbo.[OccurrenceDetailCIN].[OccurrenceDetailCINID]
	   INNER JOIN dbo.[Pattern] 
               ON Ad.[AdID] = [Pattern].[AdID] and dbo.[Pattern].[PatternID]=dbo.[OccurrenceDetailCIN].[PatternID] 
       INNER JOIN dbo.[Creative] 
               ON [Creative].[AdId] = Ad.[AdID] 
                  AND [Creative].PrimaryIndicator = 1 
                  AND [Pattern].[CreativeID] = 
                      [Creative].PK_Id  
					inner join dbo.[Configuration] on [Configuration].configurationid=[Pattern].MediaStream
					and [Configuration].systemname='All' and [Configuration].componentname='Media Stream' 
					and [Configuration].value='CIN'
GO
CREATE UNIQUE CLUSTERED INDEX [IDX_vw_UniversalSearchCinema]
    ON [dbo].[vw_UniversalSearchCinema]([AdID] ASC);

