
-- ===========================================================================================
-- Author		: Ramesh Bangi 
-- Create date	: 11/19/2015
-- Description	: Get Occurrences Data for Website Review Queue 
-- Execution	: SELECT *	FROM [vw_WebsiteReivewQueueData]
-- Updated By	: Karunakar on 25th Nov 2015,Changing AuditBy Selection.
--============================================================================================

CREATE VIEW [dbo].[vw_WebsiteReivewQueueData] 
AS
SELECT [OccurrenceDetailWEB].[OccurrenceDetailWEBID] as OccurrenceID,
			[Advertiser].Descrip as Advertiser,
			(select [Status] from OccurrenceStatus where OccurrenceStatusID = [OccurrenceDetailWEB].OccurrenceStatusID) as OccurrenceStatus,
			(select [Status] from MapStatus where MapStatusID = [OccurrenceDetailWEB].MapStatusID) as MapStatus,
			(select [Status] from IndexStatus where IndexStatusID = [OccurrenceDetailWEB].IndexStatusID) as IndexStatus,
			(select [Status] from ScanStatus where ScanStatusID = [OccurrenceDetailWEB].ScanStatusID) as ScanStatus,
			(select [Status] from QCStatus where QCStatusID = [OccurrenceDetailWEB].QCStatusID) as QCStatus,
			(select [Status] from RouteStatus where RouteStatusID = [OccurrenceDetailWEB].RouteStatusID) as RouteStatus,
			[OccurrenceDetailWEB].Priority,
			[TradeClass].Descrip as Tradeclass,
			[Market].[Descrip] as Market,
			[OccurrenceDetailWEB].[AdDT],
			(SELECT top 1 datediff(day,CreativeDetailWEB.CreativeFileDate,getdate())
FROM [Pattern] inner join CreativeDetailWEB 
on CreativeDetailWEB.CreativeMasterID = [Pattern].[CreativeID]
where [Pattern].mediastream='156'
and [Pattern].[PatternID]=[OccurrenceDetailWEB].[PatternID]
AND CreativeDetailWEB.Deleted = 0) 
 As ImageAge,			
			[Code].[Descrip] as OfficeLocation,
			[OccurrenceDetailWEB].[AdID]	AS AdID,		
			[OccurrenceDetailWEB].[AuditedByID] AS AuditByUser,
			[OccurrenceDetailWEB].[AuditedDT],
			[OccurrenceDetailWEB].[DistributionDT],
			[OccurrenceDetailWEB].[PatternID] as PatternMasterID,
			[TradeClass].[TradeClassID],
			[OccurrenceDetailWEB].AssignedtoOffice	AS LocationCode,
			[Ad].[AdvertiserID] as AdvertiserID,
			[OccurrenceDetailWEB].[MarketID] as MarketID,
			1 AS LanguageId,
			'English' As [Language],
			[USER].UserID,
			getdate()  as QryRaisedOn ,
			[OccurrenceDetailWEB].[Query]
FROM [OccurrenceDetailWEB]
LEFT JOIN  Ad ON Ad.[AdID] = [OccurrenceDetailWEB].[AdID] 
INNER JOIN  [Advertiser] ON [Advertiser].AdvertiserID = Ad.[AdvertiserID]
INNER JOIN [TradeClass] ON [TradeClass].[TradeClassID] = [Advertiser].[TradeClassID]
LEFT JOIN [Market] ON [Market].[MarketID] =[OccurrenceDetailWEB].[MarketID]	 
INNER JOIN  [Code] on [InternalDescrip] = [OccurrenceDetailWEB].AssignedtoOffice 
	AND [CodeTypeId] = 8
LEFT JOIN [USER] ON  [USER].UserID=[OccurrenceDetailWEB].[CreatedByID]
WHERE ([OccurrenceDetailWEB].[Query] IS  NULL OR [OccurrenceDetailWEB].[Query]=0)