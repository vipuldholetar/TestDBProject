

-- ===========================================================================================
-- Author		: Ramesh Bangi 
-- Create date	: 10/27/2015
-- Description	: Get Occurrences Data for Email Work Queue 
-- Execution	: SELECT *	FROM [vw_WebsiteWorkQueueData]
-- Updated By	: 
--============================================================================================

CREATE VIEW [dbo].[vw_WebsiteWorkQueueData] 
AS
SELECT [OccurrenceDetailWEB].[OccurrenceDetailWEBID]					AS OccurrenceID,
			[Advertiser].Descrip				AS Advertiser,      
			(select [Status] from OccurrenceStatus where OccurrenceStatusID = [OccurrenceDetailWEB].OccurrenceStatusID) as OccurrenceStatus,
			(select [Status] from MapStatus where MapStatusID = [OccurrenceDetailWEB].MapStatusID) as MapStatus,
			(select [Status] from IndexStatus where IndexStatusID = [OccurrenceDetailWEB].IndexStatusID) as IndexStatus,
			(select [Status] from ScanStatus where ScanStatusID = [OccurrenceDetailWEB].ScanStatusID) as ScanStatus,
			(select [Status] from QCStatus where QCStatusID = [OccurrenceDetailWEB].QCStatusID) as QCStatus,
			(select [Status] from RouteStatus where RouteStatusID = [OccurrenceDetailWEB].RouteStatusID) as RouteStatus,
			[OccurrenceDetailWEB].[Priority]			AS [Priority],
			[TradeClass].Descrip					    AS Tradeclass,
			[Market].[Descrip]				AS Market,
			[Market].[MarketID]               AS MarketCode,
			[OccurrenceDetailWEB].[AdDT]				AS AdDate,
			[Code].[Descrip]			AS OfficeLocation,  
			[OccurrenceDetailWEB].[AdID]			AS AdID, 
			[OccurrenceDetailWEB].[DistributionDT]	AS DistributionDate,
			[OccurrenceDetailWEB].[PatternID]	AS PatternMasterID,
			[TradeClass].[TradeClassID], 
			[OccurrenceDetailWEB].AssignedtoOffice	AS LocationCode,   --OccurrenceDetailsEM.OfficeLocation
			Ad.[AdvertiserID]								AS AdvertiserID,
			[OccurrenceDetailWEB].[CreatedDT]			AS CreateDate,
			[OccurrenceDetailWEB].[Query],
			1 AS LanguageId,
			'English' As [Language],
			[USER].UserID,
			getdate()  as QryRaisedOn 
FROM [OccurrenceDetailWEB] 	
INNER JOIN  AD ON Ad.[AdID] = [OccurrenceDetailWEB].[AdID]		
INNER JOIN  [Advertiser] ON [Advertiser].AdvertiserID = Ad.[AdvertiserID]	
LEFT JOIN [TradeClass] ON [TradeClass].[TradeClassID] = [Advertiser].[TradeClassID]
LEFT JOIN [Market] ON [Market].[MarketID] =[OccurrenceDetailWEB].[MarketID]	   --OUTER JOIN since Market is optional for Website
INNER JOIN  [Code] on [InternalDescrip] = [OccurrenceDetailWEB].AssignedtoOffice 
	AND [CodeTypeId] = 8
INNER JOIN [USER] ON  [USER].UserID=[OccurrenceDetailWEB].[CreatedByID]
Where ([OccurrenceDetailWEB].[Query] IS  NULL OR [OccurrenceDetailWEB].[Query]=0)
--AND OccurrenceDetailsWEB.OccurrenceStatus = 'In Progress'
--ORDER BY Priority, AdDate, Advertiser, OccurrenceID