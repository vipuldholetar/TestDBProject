-- =============================================================================  
-- Author  : KARUNAKAR  
-- Modified By  : AMRUTHA    
-- Create date : 11th Jan 2016  
-- Description : Get the Family Review Ad Data  
-- Updated By :         
-- Execution : Select * from vw_FamilyReviewData  
--===============================================================================  
 
CREATE  VIEW [dbo].[vw_FamilyReviewData]  
 AS  
 WITH CTE AS (SELECT a.[AdID] as AdID, Row_Number() OVER (partition BY a.[AdID]  
                               ORDER BY a.[AdID]) AS RN,   
 a.[OriginalAdID] as OriginalAdId ,  
   a.NoTakeAdReason as NoTakeReason,   
     a.Unclassified as Unclassified,     
  CONVERT(VARCHAR(10),a.CreateDate,20)  as CreateDTM,  
 f.AdvertiserID as AdvertiserID,  
 f.Descrip as Advertiser,  
 g.[Descrip] as Market,  
 l.[MediaTypeID] as MediaTypeID,  
 l.Descrip as MediaType,  
 i.Descrip as Theme,  
 h.Descrip as Event,  
 d.AdDate as AdDate,  
 e.[SalesStartDT] as StartDate,  
 e.[SalesEndDT] as EndDate,  
 a.[FirstRunMarketID],  
 d.PageCount as Pages,  
 j.[SizeDescrip] as Size,  
 k.Description as Language,  
 a.AdType as AdType,  
 a.AdDistribution as AdDistribution,  
 dbo.ufn_ConORDurable(d.[MediaTypeID],d.[MarketID],a.[AdvertiserID]) as EntryEligible,   
 --dbo.ufn_GetBasePath() +FIRST_VALUE(c.CreativeRepository + c.CreativeAssetName) OVER (ORDER BY c.PageNumber) as FrontPage,  
 --dbo.ufn_GetBasePath() +LAST_VALUE(c.CreativeRepository + c.CreativeAssetName) OVER (ORDER BY c.PageNumber) as BackPage, 
  dbo.ufn_GetBasePath() + dbo.ufn_FrontPage(c.CreativeMasterID,e.MediaStream) as FrontPage,
	dbo.ufn_GetBasePath() +dbo.ufn_BackPage(c.CreativeMasterID,e.MediaStream) as BackPage,  
  d.[OccurrenceDetailCIRID] as OccuranceId,    
  (select [Status] from OccurrenceStatus where OccurrenceStatusID = d.OccurrenceStatusID) as OccuranceStatus,  
  e.MediaStream as MediaStreamID  
FROM Ad a INNER JOIN [OccurrenceDetailCIR] d ON d.[OccurrenceDetailCIRID] = a.[PrimaryOccurrenceID]
INNER JOIN [Pattern] e  ON e.[PatternID] = d.[PatternID]
INNER JOIN [Creative] b ON b.PK_Id=e.[CreativeID]
INNER JOIN [Advertiser] f ON f.AdvertiserID = a.[AdvertiserID]
INNER JOIN [Language] k ON k.LanguageID = a.[LanguageID] 
INNER JOIN MediaType l ON l.[MediaTypeID] = d.[MediaTypeID]  
LEFT OUTER JOIN [Market] g ON g.[MarketID] = d.[MarketID]
LEFT OUTER JOIN [Event] h ON h.[EventID] = e.[EventID] 
LEFT OUTER JOIN [Theme] i ON i.[ThemeID] = e.[ThemeID] 
LEFT JOIN CreativeDetailCIR c ON c.CreativeMasterID = b.PK_Id
LEFT OUTER JOIN Size j ON j.[SizeID] = c.[SizeID]
WHERE b.PrimaryIndicator = 1
AND c.Deleted = 0
AND a.NoTakeAdReason is NULL  
AND a.Unclassified! = 1 
UNION   
SELECT a.[AdID] as AdID, Row_Number() OVER (partition BY a.[AdID]  
                               ORDER BY a.[AdID]) AS RN,   
 a.[OriginalAdID] as OriginalAdId ,  
   a.NoTakeAdReason as NoTakeReason,   
     a.Unclassified as Unclassified,     
  CONVERT(VARCHAR(10),a.CreateDate,20)  as CreateDTM,  
 f.AdvertiserID as AdvertiserID,  
 f.Descrip as Advertiser,  
 g.[Descrip] as Market,  
 l.[MediaTypeID] as MediaTypeID,  
 l.Descrip as MediaType,  
 i.Descrip as Theme,  
 h.Descrip as Event,  
 d.[AdDT] as AdDate,  
 e.[SalesStartDT] as StartDate,  
 e.[SalesEndDT] as EndDate,  
 a.[FirstRunMarketID],  
 d.PageCount as Pages,  
 j.[SizeDescrip] as Size,  
 k.Description as Language,  
 a.AdType as AdType,  
 a.AdDistribution as AdDistribution,  
 dbo.ufn_ConORDurable(d.[MediaTypeID],d.[MarketID],a.[AdvertiserID]) as EntryEligible,   
 --dbo.ufn_GetBasePath() +FIRST_VALUE(c.CreativeRepository + c.CreativeAssetName) OVER (ORDER BY c.PageNumber) as FrontPage,  
 --dbo.ufn_GetBasePath() +LAST_VALUE(c.CreativeRepository + c.CreativeAssetName) OVER (ORDER BY c.PageNumber) as BackPage,  
  dbo.ufn_GetBasePath() + dbo.ufn_FrontPage(c.CreativeMasterID,e.MediaStream) as FrontPage,
 dbo.ufn_GetBasePath() +dbo.ufn_BackPage(c.CreativeMasterID,e.MediaStream) as BackPage, 
  d.[OccurrenceDetailPUBID] as OccuranceId,    
  (select [Status] from OccurrenceStatus where OccurrenceStatusID = d.OccurrenceStatusID) as OccuranceStatus,  
  e.MediaStream as MediaStreamID 
FROM Ad a INNER JOIN [OccurrenceDetailPUB] d ON d.[OccurrenceDetailPUBID] = a.[PrimaryOccurrenceID]
INNER JOIN [Pattern] e  ON e.[PatternID] = d.[PatternID]
INNER JOIN [Creative] b ON b.PK_Id=e.[CreativeID]
INNER JOIN [Advertiser] f ON f.AdvertiserID = a.[AdvertiserID]
INNER JOIN [Language] k ON k.LanguageID = a.[LanguageID] 
INNER JOIN MediaType l ON l.[MediaTypeID] = d.[MediaTypeID]  
LEFT OUTER JOIN [Market] g ON g.[MarketID] = d.[MarketID]
LEFT OUTER JOIN [Event] h ON h.[EventID] = e.[EventID] 
LEFT OUTER JOIN [Theme] i ON i.[ThemeID] = e.[ThemeID] 
LEFT JOIN CreativeDetailPUB c ON c.CreativeMasterID = b.PK_Id
LEFT OUTER JOIN Size j ON j.[SizeID] = c.FK_SizeID
WHERE b.PrimaryIndicator = 1
AND c.Deleted = 0
AND a.NoTakeAdReason is NULL  
AND a.Unclassified! = 1   
UNION  
 SELECT a.[AdID] as AdID, Row_Number() OVER (partition BY a.[AdID]  
                               ORDER BY a.[AdID]) AS RN,   
 a.[OriginalAdID] as OriginalAdId ,  
   a.NoTakeAdReason as NoTakeReason,   
     a.Unclassified as Unclassified,     
  CONVERT(VARCHAR(10),a.CreateDate,20)  as CreateDTM,  
 f.AdvertiserID as AdvertiserID,  
 f.Descrip as Advertiser,  
 g.[Descrip] as Market,  
 l.[MediaTypeID] as MediaTypeID,  
 l.Descrip as MediaType,  
 i.Descrip as Theme,  
 h.Descrip as Event,  
 d.[AdDT] as AdDate,  
 e.[SalesStartDT] as StartDate,  
 e.[SalesEndDT] as EndDate,  
 a.[FirstRunMarketID],  
 --d.PageCount as Pages,  
1 as [PageCount] ,  
 j.[SizeDescrip] as Size,  
 k.Description as Language,  
 a.AdType as AdType,  
 a.AdDistribution as AdDistribution,  
 dbo.ufn_ConORDurable(d.[MediaTypeID],d.[MarketID],a.[AdvertiserID]) as EntryEligible,   
 --dbo.ufn_GetBasePath() +FIRST_VALUE(c.CreativeRepository + c.CreativeAssetName) OVER (ORDER BY c.PageNumber) as FrontPage,  
 --dbo.ufn_GetBasePath() +LAST_VALUE(c.CreativeRepository + c.CreativeAssetName) OVER (ORDER BY c.PageNumber) as BackPage,  
   dbo.ufn_GetBasePath() + dbo.ufn_FrontPage(c.CreativeMasterID,e.MediaStream) as FrontPage,
 dbo.ufn_GetBasePath() +dbo.ufn_BackPage(c.CreativeMasterID,e.MediaStream) as BackPage, 
  d.[OccurrenceDetailSOCID] as OccuranceId,    
  (select [Status] from OccurrenceStatus where OccurrenceStatusID = d.OccurrenceStatusID) as OccuranceStatus,  
  e.MediaStream as MediaStreamID 
FROM Ad a INNER JOIN [OccurrenceDetailSOC] d ON d.[OccurrenceDetailSOCID] = a.[PrimaryOccurrenceID]
INNER JOIN [Pattern] e  ON e.[PatternID] = d.[PatternID]
INNER JOIN [Creative] b ON b.PK_Id=e.[CreativeID]
INNER JOIN [Advertiser] f ON f.AdvertiserID = a.[AdvertiserID]
INNER JOIN [Language] k ON k.LanguageID = a.[LanguageID] 
INNER JOIN MediaType l ON l.[MediaTypeID] = d.[MediaTypeID]  
LEFT OUTER JOIN [Market] g ON g.[MarketID] = d.[MarketID]
LEFT OUTER JOIN [Event] h ON h.[EventID] = e.[EventID] 
LEFT OUTER JOIN [Theme] i ON i.[ThemeID] = e.[ThemeID] 
LEFT JOIN CreativeDetailSOC c ON c.CreativeMasterID = b.PK_Id
LEFT OUTER JOIN Size j ON j.[SizeID] = c.[SizeID]
WHERE b.PrimaryIndicator = 1
AND c.Deleted = 0
AND a.NoTakeAdReason is NULL  
AND a.Unclassified! = 1   
UNION   
SELECT a.[AdID] as AdID, Row_Number() OVER (partition BY a.[AdID]  
                               ORDER BY a.[AdID]) AS RN,   
 a.[OriginalAdID] as OriginalAdId ,  
   a.NoTakeAdReason as NoTakeReason,   
     a.Unclassified as Unclassified,     
  CONVERT(VARCHAR(10),a.CreateDate,20)  as CreateDTM,  
 f.AdvertiserID as AdvertiserID,  
 f.Descrip as Advertiser,  
 g.[Descrip] as Market,  
 l.[MediaTypeID] as MediaTypeID,  
 l.Descrip as MediaType,  
 i.Descrip as Theme,  
 h.Descrip as Event,  
 d.[AdDT] as AdDate,  
 e.[SalesStartDT] as StartDate,  
 e.[SalesEndDT] as EndDate,  
 a.[FirstRunMarketID],  
 1 as [PageCount] ,  
 j.[SizeDescrip] as Size,  
 k.Description as Language,  
 a.AdType as AdType,  
 a.AdDistribution as AdDistribution,  
 dbo.ufn_ConORDurable(d.[MediaTypeID],d.[MarketID],a.[AdvertiserID]) as EntryEligible,   
 --dbo.ufn_GetBasePath() +FIRST_VALUE(c.CreativeRepository + c.CreativeAssetName) OVER (ORDER BY c.PageNumber) as FrontPage,  
 --dbo.ufn_GetBasePath() +LAST_VALUE(c.CreativeRepository + c.CreativeAssetName) OVER (ORDER BY c.PageNumber) as BackPage,  
  dbo.ufn_GetBasePath() + dbo.ufn_FrontPage(c.CreativeMasterID,e.MediaStream) as FrontPage,
 dbo.ufn_GetBasePath() +dbo.ufn_BackPage(c.CreativeMasterID,e.MediaStream) as BackPage, 
  d.[OccurrenceDetailWEBID] as OccuranceId,    
  (select [Status] from OccurrenceStatus where OccurrenceStatusID = d.OccurrenceStatusID) as OccuranceStatus,  
  e.MediaStream as MediaStreamID   
	FROM Ad a INNER JOIN [OccurrenceDetailWEB] d ON d.[OccurrenceDetailWEBID] = a.[PrimaryOccurrenceID]
	INNER JOIN [Pattern] e	ON e.[PatternID] = d.[PatternID]
	INNER JOIN [Creative] b ON b.PK_Id=e.[CreativeID]
	INNER JOIN [Advertiser] f	ON f.AdvertiserID = a.[AdvertiserID]
	INNER JOIN [Language] k	ON k.LanguageID = a.[LanguageID] 
	INNER JOIN MediaType l	ON l.[MediaTypeID] = d.[MediaTypeID]  
	LEFT OUTER JOIN [Market] g	ON g.[MarketID] = d.[MarketID]
	LEFT OUTER JOIN [Event] h	ON h.[EventID] = e.[EventID] 
	LEFT OUTER JOIN [Theme] i	ON i.[ThemeID] = e.[ThemeID] 
	LEFT JOIN CreativeDetailWEB c	ON c.CreativeMasterID = b.PK_Id
	LEFT OUTER JOIN Size j	ON j.[SizeID] = c.[SizeID]
	WHERE b.PrimaryIndicator = 1
	AND c.Deleted = 0
	AND a.NoTakeAdReason is NULL  
	AND a.Unclassified! = 1       
UNION   
SELECT a.[AdID] as AdID, Row_Number() OVER (partition BY a.[AdID]  
                               ORDER BY a.[AdID]) AS RN,   
 a.[OriginalAdID] as OriginalAdId ,  
   a.NoTakeAdReason as NoTakeReason,   
     a.Unclassified as Unclassified,     
  CONVERT(VARCHAR(10),a.CreateDate,20)  as CreateDTM,  
 f.AdvertiserID as AdvertiserID,  
 f.Descrip as Advertiser,  
 g.[Descrip] as Market,  
 l.[MediaTypeID] as MediaTypeID,  
 l.Descrip as MediaType,  
 i.Descrip as Theme,  
 h.Descrip as Event,  
 d.[AdDT] as AdDate,  
 e.[SalesStartDT] as StartDate,  
 e.[SalesEndDT] as EndDate,  
 a.[FirstRunMarketID],  
 1 as [PageCount] ,  
 j.[SizeDescrip] as Size,  
 k.Description as Language,  
 a.AdType as AdType,  
 a.AdDistribution as AdDistribution,  
 dbo.ufn_ConORDurable(d.[MediaTypeID],d.[MarketID],a.[AdvertiserID]) as EntryEligible,   
 --dbo.ufn_GetBasePath() +FIRST_VALUE(c.CreativeRepository + c.CreativeAssetName) OVER (ORDER BY c.PageNumber) as FrontPage,  
 --dbo.ufn_GetBasePath() +LAST_VALUE(c.CreativeRepository + c.CreativeAssetName) OVER (ORDER BY c.PageNumber) as BackPage,  
  dbo.ufn_GetBasePath() + dbo.ufn_FrontPage(c.CreativeMasterID,e.MediaStream) as FrontPage,
 dbo.ufn_GetBasePath() +dbo.ufn_BackPage(c.CreativeMasterID,e.MediaStream) as BackPage, 
  d.[OccurrenceDetailEMID] as OccuranceId,    
  (select [Status] from OccurrenceStatus where OccurrenceStatusID = d.OccurrenceStatusID) as OccuranceStatus,  
  e.MediaStream as MediaStreamID   
  FROM Ad a INNER JOIN [OccurrenceDetailEM] d	ON d.[OccurrenceDetailEMID] = a.[PrimaryOccurrenceID]
	INNER JOIN [Pattern] e 	ON e.[PatternID] = d.[PatternID]
	INNER JOIN [Creative] b ON b.PK_Id=e.[CreativeID]
	INNER JOIN [Advertiser] f	ON f.AdvertiserID = a.[AdvertiserID]
	INNER JOIN [Language] k	ON k.LanguageID = a.[LanguageID] 
	INNER JOIN MediaType l	ON l.[MediaTypeID] = d.[MediaTypeID]  
	LEFT OUTER JOIN [Market] g	ON g.[MarketID] = d.[MarketID]
	LEFT OUTER JOIN [Event] h	ON h.[EventID] = e.[EventID] 
	LEFT OUTER JOIN [Theme] i	ON i.[ThemeID] = e.[ThemeID] 
	LEFT JOIN CreativeDetailEM c	ON c.CreativeMasterID = b.PK_Id
	LEFT OUTER JOIN Size j	ON j.[SizeID] = c.[SizeID]
	WHERE b.PrimaryIndicator = 1
	AND c.Deleted = 0
	AND a.NoTakeAdReason is NULL  
	AND a.Unclassified! = 1   
    )  
    SELECT *  
     FROM CTE  
     WHERE Rn = 1