-- ========================================================================

-- Author			: Arun Nair 

-- Create date		: 21 April 2015

-- Description		: Search Radio Ad Data   

-- Updated By		: Arun Nair on 08/11/2015 - CleanUp for OneMTDB 

--					  Arun Nair on 09/28/2015 - Added Format 

--===========================================================================





CREATE VIEW [dbo].[vw_UniversalSearchRadioClassifyPromo]

   With schemabinding

As



SELECT Ad.[AdID]                                 AS AdID, 

       Ad.[OriginalAdID], 

       Ad.[PrimaryOccurrenceID]						AS OccurrenceID, 

       [Advertiser].Descrip                 AS Advertiser, 

	   [Advertiser].AdvertiserID			AS AdvertiserID,

       CONVERT(VARCHAR, Ad.LastRunDate, 101)    AS LastRunDate, 

       CONVERT(VARCHAR, Ad.CreateDate, 101)   AS CreateDate, 

       Ad.LeadAvHeadline                        AS LeadAudio, 

       Ad.AdLength                              AS [Len], 

       Ad.LeadText                              AS LeadText, 

       [Pattern].mediastream                AS MediaStreamID, 

       Ad.RecutDetail                           AS RecutDetail, 

       [Language].description               AS Language, 

       PatternDetailRA.[RCSCreativeID]         AS CreativeSignature, 

       Ad.AdVisual                              AS Visual, 

       Ad.TaglineId, 

	   Ad.Description							AS [Description], 

       Ad.NoTakeAdReason,

	   Ad.Unclassified ,

	   [Pattern].[PatternID] AS patternmasterid,

	    'N/A' AS [Format],
		productid

FROM   dbo.Ad 

       INNER JOIN dbo.[Language] ON AD.[LanguageID] = [Language].languageid 

       INNER JOIN dbo.[Pattern] ON Ad.[AdID] = [Pattern].[AdID]

       INNER JOIN dbo.PatternDetailRA ON PatternDetailRA.[PatternID] = [Pattern].[PatternID] 

       INNER JOIN dbo.[Advertiser] ON Ad.[AdvertiserID] = [Advertiser].advertiserID 

       INNER JOIN dbo.[Creative] ON [Creative].[AdId] = AD.[AdID] 

                  AND [Creative].PrimaryIndicator = 1 

                  AND [Pattern].[CreativeID] = [Creative].PK_Id
GO
CREATE UNIQUE CLUSTERED INDEX [IDX_vw_UniversalSearchRadioClassifyPromo]
    ON [dbo].[vw_UniversalSearchRadioClassifyPromo]([AdID] ASC);

