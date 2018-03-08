







-- ========================================================================
-- Author			: Arun Nair 
-- Create date		: 21 April 2015
-- Description		: Search Radio Ad Data   
-- Updated By		: Arun Nair on 08/11/2015 - CleanUp for OneMTDB 
--					  Arun Nair on 09/28/2015 - Added Format 
--===========================================================================


CREATE VIEW [dbo].[vw_UniversalSearchRadio]
   With schemabinding
As

SELECT Ad.[AdID]                                 AS AdID, 
       Ad.[OriginalAdID], 
       -- this won't work with current indexes we have on this view  --(select min([OccurrenceDetailRAID]) from dbo.[OccurrenceDetailRA] where [OccurrenceDetailRA].[PatternId] = [Pattern].[PatternId]) as OccurrenceId,
	   null as OccurrenceId,
       [Advertiser].Descrip                 AS Advertiser, 
	   [Advertiser].AdvertiserID			AS AdvertiserID,
	   AD.ProductId,
       CONVERT(VARCHAR, Ad.LastRunDate, 101)    AS LastRunDate, 
       CONVERT(VARCHAR, Ad.CreateDate, 101)   AS CreateDate, 
       Ad.LeadAvHeadline                        AS LeadAudio, 
       Ad.AdLength                              AS [Len], 
       Ad.LeadText                              AS LeadText, 
	  [Configuration].ValueTitle AS MediaStream,
       [Pattern].mediastream                AS MediaStreamID, 
       Ad.RecutDetail                           AS RecutDetail, 
       [Language].description               AS Language, 
       Pattern.CreativeSignature        AS CreativeSignature, 
       Ad.AdVisual                              AS Visual, 
       Ad.TaglineId, 
	   Ad.Description							AS [Description], 
       Ad.NoTakeAdReason,
	   Ad.Unclassified ,
	   [Pattern].[PatternID] AS patternmasterid,
	    'N/A' AS [Format],
	   Ad.Coop1AdvId,
	   Ad.Coop2AdvId,
	   Ad.Coop3AdvId,
	   Ad.Comp1AdvId,
	   Ad.Comp2AdvId
FROM   dbo.Ad 
       INNER JOIN dbo.[Language] ON AD.[LanguageID] = [Language].languageid 
       INNER JOIN dbo.[Pattern] ON Ad.[AdID] = [Pattern].[AdID]
       INNER JOIN dbo.[Advertiser] ON Ad.[AdvertiserID] = [Advertiser].advertiserID 
       INNER JOIN dbo.[Creative] ON [Creative].[AdId] = AD.[AdID] 
                  AND [Creative].PrimaryIndicator = 1 
                  AND [Pattern].[CreativeID] = [Creative].PK_Id
	  INNER JOIN [dbo].[Configuration] on [Configuration].configurationid=[Pattern].MediaStream 
		  AND [Configuration].systemname='All' AND [Configuration].componentname='Media Stream' and [Configuration].value='RAD'
WHERE AD.Valid = 1
GO
CREATE UNIQUE CLUSTERED INDEX [IDX_vw_UniversalSearchRadio]
    ON [dbo].[vw_UniversalSearchRadio]([AdID] ASC);

