




-- ===========================================================
-- Author	   : Arun Nair 
-- Create date : 21 April 2015
-- Description : Search Circular Ad Data
-- Updated By  : Arun Nair On 07/01/2015 for Config values
-- Updated By  : Karunakar on 11th August 2015
--				 Arun Nair on 09/28/2015 - Added Format 
--=============================================================


CREATE VIEW [dbo].[vw_UniversalSearchCircular]
with schemabinding  
As

SELECT AD.[AdID]                                  AS AdID, 
       AD.[OriginalAdID], 
       AD.[PrimaryOccurrenceID]						AS OccurrenceID, 
       [Advertiser].Descrip                 AS Advertiser, 
	   [Advertiser].AdvertiserID			AS AdvertiserID,
       CONVERT(VARCHAR, AD.LastRunDate, 101)  AS LastRunDate, 
       CONVERT(VARCHAR, AD.CreateDate, 101) AS CreateDate, 
       AD.LeadAvHeadline                     AS LeadAudio, 
       AD.adlength                             AS [Len], 
       AD.leadtext                             AS LeadText, 
       [Pattern].mediastream                AS MediaStreamID, 
       AD.recutdetail                          AS RecutDetail, 
       [Language].description               AS Language, 
       ''            AS CreativeSignature, 
       advisual                                AS Visual, 
       AD.taglineid, 
	   AD.description      AS [Description], 
       AD.[notakeadreason],
	   Ad.Unclassified ,
	   'N/A' AS [Format]
 FROM   dbo.AD 
	   INNER JOIN dbo.[Language] 
               ON AD.[LanguageID] = [Language].languageid 
             INNER JOIN dbo.[Advertiser] 
               ON AD.[AdvertiserID] = [Advertiser].advertiserID 
			   inner join dbo.[OccurrenceDetailCIR] on [OccurrenceDetailCIR].[OccurrenceDetailCIRID]=AD.[PrimaryOccurrenceID] 
			   inner join dbo.[Pattern] on  [OccurrenceDetailCIR].[PatternID]=[Pattern].[PatternID]
					  inner join dbo.[Configuration] on [Pattern].mediastream=[Configuration].Configurationid				
					  and dbo.[Configuration].systemname='All' and dbo.[Configuration].componentname='Media Stream' 
					  and dbo.[Configuration].value='CIR'
GO
CREATE UNIQUE CLUSTERED INDEX [IDX_vw_UniversalSearchCircular]
    ON [dbo].[vw_UniversalSearchCircular]([AdID] ASC);

