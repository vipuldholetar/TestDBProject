-- ===========================================================================================
-- Author		: Arun Nair
-- Create date	: 11/17/2015
-- Description	: Get Occurrences Data for Social Work Queue 
-- Execution	: SELECT *	FROM [vw_SocialWorkQueueData]
-- Updated By	: 
--				  
--============================================================================================

CREATE VIEW [dbo].[vw_SocialWorkQueueData] AS
SELECT [OccurrenceDetailSOC].[OccurrenceDetailSOCID] AS OccurrenceID,
	[Advertiser].Descrip AS Advertiser,
	[Advertiser].AdvertiserID,
	[OccurrenceDetailSOC].SubjectPost AS Subject,
	(select [Status] from OccurrenceStatus where OccurrenceStatusID = [OccurrenceDetailSOC].OccurrenceStatusID) as OccurrenceStatus,
	(select [Status] from MapStatus where MapStatusID = [OccurrenceDetailSOC].MapStatusID) as MapStatus,
	(select [Status] from IndexStatus where IndexStatusID = [OccurrenceDetailSOC].IndexStatusID) as IndexStatus,
	(select [Status] from ScanStatus where ScanStatusID = [OccurrenceDetailSOC].ScanStatusID) as ScanStatus,
	(select [Status] from QCStatus where QCStatusID = [OccurrenceDetailSOC].QCStatusID) as QCStatus,
	(select [Status] from RouteStatus where RouteStatusID = [OccurrenceDetailSOC].RouteStatusID) as RouteStatus,
	[OccurrenceDetailSOC].Priority,
	[TradeClass].Descrip AS Tradeclass,
	[Market].[Descrip] AS Market,
	[OccurrenceDetailSOC].[AdDT],
(SELECT TOP 1 Datediff(Day,CreativeDetailSOC.CreativeFileDate,getdate())
FROM [Pattern] inner join CreativeDetailSOC 
ON CreativeDetailSOC.CreativeMasterID = [Pattern].[CreativeID]
WHERE [Pattern].MediaStream='155' 
AND [Pattern].[PatternID]=[OccurrenceDetailSOC].[PatternID]
AND CreativeDetailSOC.Deleted = 0) AS ImageAge,
	[Code].[Descrip] AS OfficeLocation,
	Ad.[AdID] AS AdID,	
	[OccurrenceDetailSOC].LandingPageURL AS LPURL,
	[OccurrenceDetailSOC].URL,
	[OccurrenceDetailSOC].[DistributionDT],
	[OccurrenceDetailSOC].[PatternID] AS PatternMasterID,
	[TradeClass].[TradeClassID] AS TradeclassID,
	[OccurrenceDetailSOC].AssignedtoOffice AS LocationCode,	
	[OccurrenceDetailSOC].[CreatedDT] AS CreateDate,
	[OccurrenceDetailSOC].FormatCode,
	[OccurrenceDetailSOC].RatingCode,
	[OccurrenceDetailSOC].CountryOrigin,
	[Language].LanguageID,
	[Language].[Description] as   [Language],
	getdate()  as QryRaisedOn,
	SocialType,
	UserID
FROM [OccurrenceDetailSOC] LEFT JOIN  Ad ON Ad.[AdID] = [OccurrenceDetailSOC].[AdID] 
LEFT JOIN  [Advertiser] ON [Advertiser].AdvertiserID = Ad.[AdvertiserID] 
LEFT JOIN [TradeClass] ON [TradeClass].[TradeClassID] = [Advertiser].[TradeClassID]
INNER JOIN [Market] ON [Market].[MarketID] = [OccurrenceDetailSOC].[MarketID]
INNER JOIN  [Code] on [InternalDescrip] = [OccurrenceDetailSOC].AssignedtoOffice 
	AND [CodeTypeId] = 8
INNER JOIN [USER] ON  [USER].UserID=[OccurrenceDetailSOC].[CreatedByID]
LEFT JOIN [Language] ON [Language].LanguageID=Ad.[LanguageID]
WHERE ([OccurrenceDetailSOC].SocialType = 'PROMO' OR [OccurrenceDetailSOC].SocialType ='BRAND') AND
 ([OccurrenceDetailSOC].[Query] =0 OR  [OccurrenceDetailSOC].[Query] IS NULL)