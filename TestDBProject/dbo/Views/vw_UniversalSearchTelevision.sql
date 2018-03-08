






-- =================================================================
-- Author			: Murali Jaganathan 
-- Create date		: 9th jULY 2015
-- Description		: Search Television Ad Data   
-- Updated By		: Arun on 08/13/2015 - Cleanup OnemT 
--					  Arun Nair On 09/28/2015 - Added Format 
--====================================================================

CREATE VIEW [dbo].[vw_UniversalSearchTelevision] 
 with Schemabinding
As
SELECT AD.[AdID]                        AS AdID, 
AD.[OriginalAdID], 
AD.[PrimaryOccurrenceID]                     AS OccurrenceID, 
[Advertiser].Descrip               AS Advertiser, 
[Advertiser].AdvertiserID          AS AdvertiserID,
CONVERT(VARCHAR, AD.LastRunDate, 101)  AS LastRunDate, 
CONVERT(VARCHAR, AD.CreateDate, 101) AS CreateDate, 
AD.LeadAvHeadline                      AS LeadAudio, 
AD.AdLength                            AS [Len], 
AD.LeadText                            AS LeadText, 
[Pattern].mediastream              AS MediaStreamID, 
AD.RecutDetail                         AS RecutDetail, 
[Language].description             AS Language, 
[OccurrenceDetailTV].[PRCODE]            AS CreativeSignature, 
AdVisual                               AS Visual, 
AD.taglineid, 
AD.description           AS [Description], 
AD.[notakeadreason],
Ad.Unclassified ,
[Pattern].[PatternID] as patternmasterid,
 'N/A' AS [Format]
FROM   dbo.AD 
	INNER JOIN dbo.[Language] ON AD.[LanguageID] = [Language].languageid 
	INNER JOIN dbo.[Advertiser] ON AD.[AdvertiserID] = [Advertiser].advertiserID 
	INNER JOIN dbo.[OccurrenceDetailTV] ON Ad.[PrimaryOccurrenceID]=dbo.[OccurrenceDetailTV].[OccurrenceDetailTVID]                     
	INNER JOIN dbo.[Pattern] ON AD.[AdID] = [Pattern].[AdID]
	INNER JOIN dbo.[Creative] ON [Creative].[AdId] = AD.[AdID]
	AND [Creative].primaryindicator = 1 AND [Pattern].[CreativeID]=[Creative].PK_Id
	 INNER JOIN dbo.[Configuration] ON [Pattern].mediastream=[Configuration].Configurationid
				  AND dbo.[Configuration].systemname='All' and dbo.[Configuration].componentname='Media Stream' 
				  AND  dbo.[Configuration].value='TV'
GO
CREATE UNIQUE CLUSTERED INDEX [IDX_vw_UniversalSearchTelevision]
    ON [dbo].[vw_UniversalSearchTelevision]([AdID] ASC);

