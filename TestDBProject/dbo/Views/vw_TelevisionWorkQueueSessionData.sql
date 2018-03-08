
--====================================================================================================
-- Author			: Murali Jaganathan
-- Create date		: 
-- Description		: Get Session Data for TV Work Queue 
-- Execution		: Select * from [dbo].[vw_TelevisionWorkQueueSessionData]
-- Updated By		: Arun Nair on 07/09/2015 -Added mpg ,FK_CreativeMasterStagingId null check
--					: Karunakar on 15th Sep 2015,Adding fk_adid and PatternMasterId Check 
--					: Arun Nair on 12/02/2015 - MI-223 Added Ethnicity for language
--====================================================================================================
CREATE VIEW  [dbo].[vw_TelevisionWorkQueueSessionData]
AS
SELECT 
[Configuration].[ValueTitle]  AS WorkType,
[PatternStaging].[WorkType] AS WorkTypeId,
[Market].[Descrip] AS City, 
[Market].TVOccurrenceThreshold,
convert(date,[OccurrenceDetailTV].[AirDT]) AS FirstAirDate, 
[OccurrenceDetailTV].[PRCODE] AS CreativeSignatureCount, 
'' AS TotalQScore,
[PatternStaging].ScoreQ, 
[OccurrenceDetailTV].CaptureStationCode,
[TVStation].StationShortName,  
[PatternStaging].[CreativeSignature] AS PRCODE, 
[OccurrenceDetailTV].[OccurrenceDetailTVID],
[OccurrenceDetailTV].AdLength AS Length,
[PatternStaging].[Query] As QAndA,
[PatternStaging].[Exception] AS IsException,
[PatternStaging].[LanguageID],
[TVStation].StationFullName AS MediaOutlet,
'' AS Advertiser,
[PatternStaging].[Priority] AS [Priority],
[dbo].[QueryDetail].[QueryText],
[dbo].[Language].[Description] AS [Language],
[Market].[MarketID] AS MarketID,
[PatternStaging].[PatternStagingID] AS PatternMasterStagingId,
[RefEthnicGroup].EthnicGroupName,
[RefEthnicGroup].[RefEthnicGroupID] AS EthnicGroupId
FROM    [OccurrenceDetailTV] 
INNER JOIN  TVRecordingSchedule ON [OccurrenceDetailTV].[TVRecordingScheduleID] = TVRecordingSchedule.[TVRecordingScheduleID]
INNER JOIN  [TVStation] ON [TVRecordingSchedule].[TVStationID] = [TVStation].[TVStationID]
INNER JOIN [Market] ON [TVStation].[MarketID] = [Market].[MarketID]
INNER JOIN  [PatternStaging] ON [PatternStaging].[CreativeSignature] = [OccurrenceDetailTV].[PRCODE] and MediaStream = 144
LEFT JOIN [Language] ON [dbo].[Language].[LanguageID]=[dbo].[PatternStaging].[LanguageID]
LEFT JOIN RefEthnicGroup ON [dbo].[RefEthnicGroup].[RefEthnicGroupID]=[dbo].[Language].[EthnicGroupID]
LEFT JOIN [QueryDetail] ON [dbo].[QueryDetail].[PatternStgID]=[PatternStaging].[PatternStagingID]
INNER JOIN [dbo].[Configuration] on [dbo].[Configuration].Value=[dbo].[PatternStaging].[WorkType] 
AND [dbo].[Configuration].[ComponentName]='WorkType' AND [dbo].[Configuration].Systemname='All'
AND [CreativeStgID] IS NOT NULL 
AND [dbo].[OccurrenceDetailTV].[AdID] IS NULL