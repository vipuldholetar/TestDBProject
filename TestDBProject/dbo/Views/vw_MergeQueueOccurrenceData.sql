


-- =============================================================================  
-- Author  : KARUNAKAR    
-- Create date : 4th Jan 2016  
-- Description : Get the Merge Occurrence Data for Circular  
-- Updated By :         
-- Execution : Select * from vw_MergeQueueOccurrenceData  
--===============================================================================  
  
CREATE  VIEW [dbo].[vw_MergeQueueOccurrenceData]  
AS  
  
--Circular  
WITH CTE AS (  
     SELECT d.[OccurrenceDetailCIRID], Row_Number() OVER (partition BY d.[OccurrenceDetailCIRID]  
          ORDER BY d.[OccurrenceDetailCIRID]) AS RN, a.[AdID] as AdID,  
     CONVERT(VARCHAR(10),a.CreateDate,20)  as CreateDTM,  
     g.[Descrip] as Market,  
     l.Descrip as MediaType,  
     i.Descrip as Theme,  
     h.Descrip as Event,  
     a.[CommonAdDT] as AdDate,  
     e.[SalesStartDT] as StartDate,  
     e.[SalesEndDT] as EndDate,  
     a.[FirstRunMarketID] as FirstMarket,  
     d.PageCount as Pages,  
     k.Description as Language,  
     (select [Status] from OccurrenceStatus where OccurrenceStatusID = d.OccurrenceStatusID) as Status,  
     e.[FlashInd] as FlashStatus,  
     d.FlyerID as FlyerID,  
     FIRST_VALUE (c.[SizeID])OVER (ORDER BY c.PageNumber) as SizeID,  
     --dbo.ufn_GetBasePath() +LAST_VALUE(c.CreativeRepository + c.CreativeAssetName) OVER (ORDER BY c.PageNumber) as BackPage, 
	-- dbo.ufn_GetBasePath() +FIRST_VALUE(c.CreativeRepository + c.CreativeAssetName) OVER (ORDER BY c.PageNumber) as FrontPage,
	dbo.ufn_GetBasePath() +dbo.ufn_BackPage(c.CreativeMasterID,e.MediaStream) as BackPage,
	dbo.ufn_GetBasePath() + dbo.ufn_FrontPage(c.CreativeMasterID,e.MediaStream) as FrontPage,    
     s.[SizeDescrip] as SizeDescription,  
     Adv.Descrip as Advertiser,  
     e.MediaStream  
     
	 FROM Ad a INNER JOIN [OccurrenceDetailCIR] d ON d.[AdID] = a.[AdID]
              INNER JOIN [Pattern] e ON e.[PatternID] = d.[PatternID]
              INNER JOIN [Advertiser] Adv ON Adv.AdvertiserID = a.[AdvertiserID]
              LEFT OUTER JOIN [Market] g on g.[MarketID]=d.[MarketID]          
              LEFT OUTER JOIN [Event] h ON h.[EventID] = e.[EventID] 
              LEFT OUTER JOIN [Theme] i ON i.[ThemeID] = e.[ThemeID] 
              INNER JOIN [Language] k ON k.LanguageID = a.[LanguageID]
              INNER JOIN MediaType l ON l.[MediaTypeID] = d.[MediaTypeID] 
			  INNER JOIN [Creative] b ON b.Pk_Id = e.[CreativeID]  
              LEFT OUTER JOIN CreativeDetailCIR c ON b.Pk_Id = c.CreativeMasterId and c.deleted=0
              LEFT OUTER JOIN Size s ON s.[SizeID] = c.[SizeID]   
UNION --Publication  
     SELECT d.[OccurrenceDetailPUBID], Row_Number() OVER (partition BY d.[OccurrenceDetailPUBID]  
             ORDER BY d.[OccurrenceDetailPUBID]) AS RN, a.[AdID] as AdID,  
     CONVERT(VARCHAR(10),a.CreateDate,20)  as CreateDTM,  
     g.[Descrip] as Market,  
     l.Descrip as MediaType,  
     i.Descrip as Theme,  
     h.Descrip as Event,  
     a.[CommonAdDT] as AdDate,  
     e.[SalesStartDT] as StartDate,  
     e.SalesEndDT as EndDate,  
     a.[FirstRunMarketID] as FirstMarket,   
     d.PageCount as Pages,  
     k.Description as Language,  
     (select [Status] from OccurrenceStatus where OccurrenceStatusID = d.OccurrenceStatusID) as Status,  
     e.[FlashInd] as FlashStatus,  
     d.FlyerID as FlyerID,  
     FIRST_VALUE (c.FK_SizeID)OVER (ORDER BY c.PageNumber) as SizeID,     
	 --dbo.ufn_GetBasePath() +LAST_VALUE(c.CreativeRepository + c.CreativeAssetName) OVER (ORDER BY c.PageNumber) as BackPage, 
	 --dbo.ufn_GetBasePath() +FIRST_VALUE(c.CreativeRepository + c.CreativeAssetName) OVER (ORDER BY c.PageNumber) as FrontPage,
	 dbo.ufn_GetBasePath() +dbo.ufn_BackPage(c.CreativeMasterID,e.MediaStream) as BackPage,
	 dbo.ufn_GetBasePath() + dbo.ufn_FrontPage(c.CreativeMasterID,e.MediaStream) as FrontPage,     
     s.[SizeDescrip] as SizeDescription,  
     Adv.Descrip as Advertiser,  
     e.MediaStream
        
	  FROM Ad a INNER JOIN [OccurrenceDetailPUB] d ON d.[AdID] = a.[AdID]
              INNER JOIN [Pattern] e ON e.[PatternID] = d.[PatternID]
              INNER JOIN [Advertiser] Adv ON Adv.AdvertiserID = a.[AdvertiserID]
              LEFT OUTER JOIN [Market] g on g.[MarketID]=d.[MarketID]          
              LEFT OUTER JOIN [Event] h ON h.[EventID] = e.[EventID] 
              LEFT OUTER JOIN [Theme] i ON i.[ThemeID] = e.[ThemeID] 
              INNER JOIN [Language] k ON k.LanguageID = a.[LanguageID]
              INNER JOIN MediaType l ON l.[MediaTypeID] = d.[MediaTypeID] 
              INNER JOIN [Creative] b ON b.Pk_Id = e.[CreativeID]   
              LEFT OUTER JOIN CreativeDetailPUB c ON b.Pk_Id = c.CreativeMasterId and c.deleted=0
              LEFT OUTER JOIN Size s ON s.[SizeID] = c.FK_SizeID
   
UNION    --Email  
      SELECT d.[OccurrenceDetailEMID] as PK_OccurrenceID, Row_Number() OVER (partition BY d.[OccurrenceDetailEMID]  
              ORDER BY d.[OccurrenceDetailEMID]) AS RN, a.[AdID] as AdID,  
      CONVERT(VARCHAR(10),a.CreateDate,20)  as CreateDTM,  
      g.[Descrip] as Market,  
      l.Descrip as MediaType,  
      i.Descrip as Theme,  
      h.Descrip as Event,  
      a.[CommonAdDT] as AdDate,  
      e.[SalesStartDT] as StartDate,  
      e.SalesEndDT as EndDate,  
      a.[FirstRunMarketID] as FirstMarket,   
      1 as Pages,  
      k.Description as Language,  
     (select [Status] from OccurrenceStatus where OccurrenceStatusID = d.OccurrenceStatusID) as Status,  
      e.[FlashInd] as FlashStatus,  
      d.FlyerID as FlyerID,  
      FIRST_VALUE (c.[SizeID])OVER (ORDER BY c.PageNumber) as SizeID,  
   --   dbo.ufn_GetBasePath() +LAST_VALUE(c.CreativeRepository + c.CreativeAssetName) OVER (ORDER BY c.PageNumber) as BackPage, 
	  --dbo.ufn_GetBasePath() +FIRST_VALUE(c.CreativeRepository + c.CreativeAssetName) OVER (ORDER BY c.PageNumber) as FrontPage,
	  dbo.ufn_GetBasePath() +dbo.ufn_BackPage(c.CreativeMasterID,e.MediaStream) as BackPage,
	 dbo.ufn_GetBasePath() + dbo.ufn_FrontPage(c.CreativeMasterID,e.MediaStream) as FrontPage,    
      s.[SizeDescrip] as SizeDescription,  
      Adv.Descrip as Advertiser,  
      e.MediaStream  
       
	  FROM Ad a INNER JOIN [OccurrenceDetailEM] d ON d.[AdID] = a.[AdID]
              INNER JOIN [Pattern] e ON e.[PatternID] = d.[PatternID]
              INNER JOIN [Advertiser] Adv ON Adv.AdvertiserID = a.[AdvertiserID]
              LEFT OUTER JOIN [Market] g on g.[MarketID]=d.[MarketID]          
              LEFT OUTER JOIN [Event] h ON h.[EventID] = e.[EventID] 
              LEFT OUTER JOIN [Theme] i ON i.[ThemeID] = e.[ThemeID] 
              INNER JOIN [Language] k ON k.LanguageID = a.[LanguageID]
              INNER JOIN MediaType l ON l.[MediaTypeID] = d.[MediaTypeID] 
              INNER JOIN [Creative] b ON b.Pk_Id = e.[CreativeID] 
              LEFT OUTER JOIN CreativeDetailEM c ON b.Pk_Id = c.CreativeMasterId and c.deleted=0
              LEFT OUTER JOIN Size s ON s.[SizeID] = c.[SizeID]
  
  
UNION    --Website  
      SELECT d.[OccurrenceDetailWEBID] as PK_OccurrenceID, Row_Number() OVER (partition BY d.[OccurrenceDetailWEBID]  
              ORDER BY d.[OccurrenceDetailWEBID]) AS RN, a.[AdID] as AdID,  
      CONVERT(VARCHAR(10),a.CreateDate,20)  as CreateDTM,  
      g.[Descrip] as Market,  
      l.Descrip as MediaType,  
      i.Descrip as Theme,  
      h.Descrip as Event,  
      a.[CommonAdDT] as AdDate,  
      e.[SalesStartDT] as StartDate,  
      e.SalesEndDT as EndDate,  
      a.[FirstRunMarketID] as FirstMarket, 
      1 as Pages,  
      k.Description as Language,  
     (select [Status] from OccurrenceStatus where OccurrenceStatusID = d.OccurrenceStatusID) as Status,  
      e.[FlashInd] as FlashStatus,  
      d.FlyerID as FlyerID,  
      FIRST_VALUE (c.[SizeID])OVER (ORDER BY c.PageNumber) as SizeID,  
   --   dbo.ufn_GetBasePath() +LAST_VALUE(c.CreativeRepository + c.CreativeAssetName) OVER (ORDER BY c.PageNumber) as BackPage, 
	  --dbo.ufn_GetBasePath() +FIRST_VALUE(c.CreativeRepository + c.CreativeAssetName) OVER (ORDER BY c.PageNumber) as FrontPage,  
	  dbo.ufn_GetBasePath() +dbo.ufn_BackPage(c.CreativeMasterID,e.MediaStream) as BackPage,
	 dbo.ufn_GetBasePath() + dbo.ufn_FrontPage(c.CreativeMasterID,e.MediaStream) as FrontPage,   
      s.[SizeDescrip] as SizeDescription,  
      Adv.Descrip as Advertiser,  
      e.MediaStream  
      
	  FROM Ad a INNER JOIN [OccurrenceDetailWEB] d ON d.[AdID] = a.[AdID]
              INNER JOIN [Pattern] e ON e.[PatternID] = d.[PatternID]
              INNER JOIN [Advertiser] Adv ON Adv.AdvertiserID = a.[AdvertiserID]
              LEFT OUTER JOIN [Market] g on g.[MarketID]=d.[MarketID]          
              LEFT OUTER JOIN [Event] h ON h.[EventID] = e.[EventID] 
              LEFT OUTER JOIN [Theme] i ON i.[ThemeID] = e.[ThemeID] 
              INNER JOIN [Language] k ON k.LanguageID = a.[LanguageID]
              INNER JOIN MediaType l ON l.[MediaTypeID] = d.[MediaTypeID] 
              INNER JOIN [Creative] b ON b.Pk_Id = e.[CreativeID]  
              LEFT OUTER JOIN CreativeDetailWeb c ON b.Pk_Id = c.CreativeMasterId and c.deleted=0
              LEFT OUTER JOIN Size s ON s.[SizeID] = c.[SizeID]
UNION --Social  
     SELECT d.[OccurrenceDetailSOCID], Row_Number() OVER (partition BY d.[OccurrenceDetailSOCID]  
             ORDER BY d.[OccurrenceDetailSOCID]) AS RN, a.[AdID] as AdID,  
     CONVERT(VARCHAR(10),a.CreateDate,20)  as CreateDTM,  
     g.[Descrip] as Market,  
     l.Descrip as MediaType,  
     i.Descrip as Theme,  
     h.Descrip as Event,  
     a.[CommonAdDT] as AdDate,  
     e.[SalesStartDT] as StartDate,  
     e.SalesEndDT as EndDate,  
     a.[FirstRunMarketID] as FirstMarket, 
     1 as Pages,  
     k.Description as Language,  
     (select [Status] from OccurrenceStatus where OccurrenceStatusID = d.OccurrenceStatusID) as Status,  
     e.[FlashInd] as FlashStatus,  
     d.FlyerID as FlyerID,  
     FIRST_VALUE (c.[SizeID])OVER (ORDER BY c.PageNumber) as SizeID,  
   --  dbo.ufn_GetBasePath() +LAST_VALUE(c.CreativeRepository + c.CreativeAssetName) OVER (ORDER BY c.PageNumber) as BackPage, 
	  --dbo.ufn_GetBasePath() +FIRST_VALUE(c.CreativeRepository + c.CreativeAssetName) OVER (ORDER BY c.PageNumber) as FrontPage,  
	  dbo.ufn_GetBasePath() +dbo.ufn_BackPage(c.CreativeMasterID,e.MediaStream) as BackPage,
	dbo.ufn_GetBasePath() + dbo.ufn_FrontPage(c.CreativeMasterID,e.MediaStream) as FrontPage,   
     s.[SizeDescrip] as SizeDescription,  
     Adv.Descrip as Advertiser,  
     e.MediaStream  
       
	 FROM Ad a INNER JOIN [OccurrenceDetailSOC] d ON d.[AdID] = a.[AdID]
              INNER JOIN [Pattern] e ON e.[PatternID] = d.[PatternID]
              INNER JOIN [Advertiser] Adv ON Adv.AdvertiserID = a.[AdvertiserID]
              LEFT OUTER JOIN [Market] g on g.[MarketID]=d.[MarketID]          
              LEFT OUTER JOIN [Event] h ON h.[EventID] = e.[EventID] 
              LEFT OUTER JOIN [Theme] i ON i.[ThemeID] = e.[ThemeID] 
              INNER JOIN [Language] k ON k.LanguageID = a.[LanguageID]
              INNER JOIN MediaType l ON l.[MediaTypeID] = d.[MediaTypeID] 
             INNER JOIN [Creative] b ON b.Pk_Id = e.[CreativeID]  
              LEFT OUTER JOIN CreativeDetailSOC c ON b.Pk_Id = c.CreativeMasterId and c.deleted=0
              LEFT OUTER JOIN Size s ON s.[SizeID] = c.[SizeID]
  
 )  
    SELECT * FROM CTE  WHERE Rn = 1