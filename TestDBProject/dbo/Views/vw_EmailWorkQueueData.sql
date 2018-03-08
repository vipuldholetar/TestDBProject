-- ===========================================================================================
-- Author		: Ramesh Bangi 
-- Create date	: 10/19/2015
-- Description	: Get Occurrences Data for Email Work Queue 
-- Execution	: SELECT *	FROM [vw_EmailWorkQueueData]
-- Updated By	: Arun Nair on 11/03/2015 - Updated LanguageId,Language from LanguageMaster,Ad 
--				  
--============================================================================================

CREATE VIEW [dbo].[vw_EmailWorkQueueData] 
AS
SELECT [OccurrenceDetailEM].[OccurrenceDetailEMID]					AS OccurrenceID,
			[Advertiser].Descrip				AS Advertiser,
			[OccurrenceDetailEM].SubjectLine			AS [Subject],
			SenderPersona.SenderName				AS Sender,       
			[OccurrenceDetailEM].[Priority]			AS [Priority],
			[TradeClass].Descrip					    AS Tradeclass,
			[Market].[Descrip]				AS Market,
			[Market].[MarketID]               AS MarketCode,
			[OccurrenceDetailEM].[AdDT]				AS AdDate,
			dbo.PatternStaging.Exception,
			(SELECT top 1 datediff(day,CreativeDetailEM.CreativeFileDate,getdate())
FROM [Pattern] inner join CreativeDetailEM 
on CreativeDetailEM.CreativeMasterID = [Pattern].[CreativeID]
where [Pattern].mediastream='154'
and [Pattern].[PatternID]=[OccurrenceDetailEM].[PatternID]

AND CreativeDetailEM.Deleted = 0) as ImageAge,
			[Code].[Descrip]			AS OfficeLocation,  
			[OccurrenceDetailEM].[AdID]				AS AdID, 
			[OccurrenceDetailEM].[AdvertiserEmailID] AS SourceEmail,
			(select LandingURL from LandingPage where LandingPage.LandingPageID = OccurrenceDetailEM.LandingPageID)		AS LandingPageURL,
			[OccurrenceDetailEM].[DistributionDT]	AS DistributionDate,
			[OccurrenceDetailEM].[PatternID]	AS PatternMasterID,
			[TradeClass].[TradeClassID], 
			[OccurrenceDetailEM].AssignedtoOffice	AS LocationCode,   --OccurrenceDetailsEM.OfficeLocation
			[OccurrenceDetailEM].[AdvertiserID]		AS AdvertiserID,
			[OccurrenceDetailEM].[CreatedDT]			AS CreateDate,
			[OccurrenceDetailEM].[Query],
			[OccurrenceStatusMain].Status	AS OccurrenceStatus,
			[OccurrenceMapStatus].Status			AS MapStatus,
			[OccurrenceIndexStatus].Status			AS IndexStatus,
			[OccurrenceScanStatus].Status			AS ScanStatus,
			[OccurrenceQCStatus].Status			AS QCStatus,
			[OccurrenceRouteStatus].Status			AS RouteStatus,
			[Language].LanguageID,
			[Language].[Description] as   [Language],
			[USER].UserID,
			getdate()  as QryRaisedOn ,
			[OccurrenceDetailEM].[ParentOccurrenceID]	 AS ParentOccurrenceId,
			[OccurrenceDetailEM].[MarketID] as MarketID
FROM [OccurrenceDetailEM]
LEFT JOIN  Ad ON Ad.[AdID] = [OccurrenceDetailEM].[AdID] -- LEFT JOIN since ingested Email Occurrences initially need map,
INNER JOIN  [Advertiser] ON [Advertiser].AdvertiserID = [OccurrenceDetailEM].[AdvertiserID] 
INNER JOIN  SenderPersona ON SenderPersona.[SenderPersonaID] = [OccurrenceDetailEM].[SenderPersonaID]
INNER JOIN [TradeClass] ON [TradeClass].[TradeClassID] = [Advertiser].[TradeClassID]
INNER JOIN [Market] ON [Market].[MarketID] = [OccurrenceDetailEM].[MarketID]
INNER JOIN  [Code] on [InternalDescrip] = [OccurrenceDetailEM].AssignedtoOffice 
	AND [CodeTypeId] = 8
INNER JOIN [USER] ON  [USER].UserID=[OccurrenceDetailEM].[CreatedByID]
LEFT JOIN [Language] ON [Language].LanguageID=Ad.[LanguageID]
LEFT JOIN [OccurrenceStatus] as OccurrenceStatusMain ON [OccurrenceStatusMain].OccurrenceStatusID = [OccurrenceDetailEM].OccurrenceStatusID
LEFT JOIN [OccurrenceStatus] as OccurrenceMapStatus ON [OccurrenceMapStatus].OccurrenceStatusID = [OccurrenceDetailEM].MapStatusID
LEFT JOIN [OccurrenceStatus] as OccurrenceIndexStatus ON [OccurrenceIndexStatus].OccurrenceStatusID = [OccurrenceDetailEM].IndexStatusID
LEFT JOIN [OccurrenceStatus] as OccurrenceScanStatus ON [OccurrenceScanStatus].OccurrenceStatusID = [OccurrenceDetailEM].ScanStatusID
LEFT JOIN [OccurrenceStatus] as OccurrenceQCStatus ON [OccurrenceQCStatus].OccurrenceStatusID = [OccurrenceDetailEM].RouteStatusID
LEFT JOIN [OccurrenceStatus] as OccurrenceRouteStatus ON [OccurrenceRouteStatus].OccurrenceStatusID = [OccurrenceDetailEM].RouteStatusID
LEFT JOIN dbo.PatternStaging ON dbo.OccurrenceDetailEM.PatternID = dbo.PatternStaging.PatternID

WHERE ([OccurrenceDetailEM].[Query] IS  NULL OR [OccurrenceDetailEM].[Query]=0)
AND [OccurrenceDetailEM].[ParentOccurrenceID] IS NULL