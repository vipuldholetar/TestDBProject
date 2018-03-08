





-- ===========================================================================================
-- Author		: Ramesh Bangi 
-- Create date	: 11/2/2015
-- Description	: Get Occurrences Data for Email Work Queue 
-- Execution	: SELECT *	FROM [vw_EmailReivewQueueData]
-- Updated By	:
--============================================================================================

CREATE VIEW [dbo].[vw_EmailReivewQueueData] 
AS
SELECT [OccurrenceDetailEM].[OccurrenceDetailEMID] as OccurrenceID,
			[Advertiser].Descrip as Advertiser,
			[OccurrenceDetailEM].SubjectLine as [Subject],
			[SenderPersona].SenderName as Sender,
			(select [Status] from OccurrenceStatus where OccurrenceStatusID = [OccurrenceDetailEM].OccurrenceStatusID) as OccurrenceStatus,
			(select [Status] from MapStatus where MapStatusID = [OccurrenceDetailEM].MapStatusID) as MapStatus,
			(select [Status] from IndexStatus where IndexStatusID = [OccurrenceDetailEM].IndexStatusID) as IndexStatus,
			(select [Status] from ScanStatus where ScanStatusID = [OccurrenceDetailEM].ScanStatusID) as ScanStatus,
			(select [Status] from QCStatus where QCStatusID = [OccurrenceDetailEM].QCStatusID) as QCStatus,
			(select [Status] from RouteStatus where RouteStatusID = [OccurrenceDetailEM].RouteStatusID) as RouteStatus,
			[OccurrenceDetailEM].Priority,
			[TradeClass].Descrip as Tradeclass,
			[Market].[Descrip] as Market,
			[OccurrenceDetailEM].[AdDT],
			(SELECT top 1 datediff(day,CreativeDetailEM.CreativeFileDate,getdate())
FROM [Pattern] inner join CreativeDetailEM 
on CreativeDetailEM.CreativeMasterID = [Pattern].[CreativeID]
where [Pattern].mediastream='154'
and [Pattern].[PatternID]=[OccurrenceDetailEM].[PatternID]
AND CreativeDetailEM.Deleted = 0) 
 As ImageAge,
			[Code].[Descrip] as OfficeLocation,
			[OccurrenceDetailEM].[AdID]	AS AdID,
			[OccurrenceDetailEM].[AuditedByID] AS AuditByUser,
			[OccurrenceDetailEM].[AuditedDT],
			[OccurrenceDetailEM].[AdvertiserEmailID] as SourceEmail,
			(select LandingURL from LandingPage where LandingPage.LandingPageID = OccurrenceDetailEM.LandingPageID) as LPURL,
			[OccurrenceDetailEM].[DistributionDT],
			[OccurrenceDetailEM].[PatternID] as PatternMasterID,
			[TradeClass].[TradeClassID],
			[OccurrenceDetailEM].AssignedtoOffice	AS LocationCode,
			[OccurrenceDetailEM].[AdvertiserID] as AdvertiserID,
			[OccurrenceDetailEM].[MarketID] as MarketID,
			1 AS LanguageId,
			'English' As [Language],
			[USER].UserID,
			getdate()  as QryRaisedOn ,
			[OccurrenceDetailEM].[Query],
			[OccurrenceDetailEM].[ParentOccurrenceID]	 AS ParentOccurrenceId
FROM [OccurrenceDetailEM]
LEFT JOIN  Ad ON Ad.[AdID] = [OccurrenceDetailEM].[AdID] -- LEFT JOIN since ingested Email Occurrences initially need map,
INNER JOIN  [Advertiser] ON [Advertiser].AdvertiserID = [OccurrenceDetailEM].[AdvertiserID] 
INNER JOIN  SenderPersona ON SenderPersona.[SenderPersonaID] = [OccurrenceDetailEM].[SenderPersonaID]
INNER JOIN [TradeClass] ON [TradeClass].[TradeClassID] = [Advertiser].[TradeClassID]
INNER JOIN [Market] ON [Market].[MarketID] = [OccurrenceDetailEM].[MarketID]
INNER JOIN  [Code] on [InternalDescrip] = [OccurrenceDetailEM].AssignedtoOffice 
	AND [CodeTypeId] = 8
LEFT JOIN [USER] ON  [USER].UserID=[OccurrenceDetailEM].[CreatedByID]
WHERE ([OccurrenceDetailEM].[Query] IS  NULL OR [OccurrenceDetailEM].[Query]=0)
AND [OccurrenceDetailEM].[ParentOccurrenceID] IS NULL