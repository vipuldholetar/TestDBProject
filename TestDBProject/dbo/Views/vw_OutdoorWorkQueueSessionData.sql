

-- ===========================================================================================================================================
-- Author		: Arun Nair 
-- Create date	: 07/06/2015
-- Execution	: SELECT * from [dbo].[vw_OutdoorWorkQueueSessionData]
-- Description	: Get Session Data for Outdoor Work Queue 
-- Updated By	: Arun Nair on 07/14/2015 for getting Work Type from ConfigurationMaster
--				  Arun Nair on 07/22/2015 Commented [dbo].[CreativeDetailsODRStg].[Format] AS CreativeDetailsODRStgFormat  as Not in table 
--				  Karunakar on 09/15/2015,Adding Adid and Patternmasterid Check
--				  Arun Nair on 11/24/2015 - Added AuditBy,AuditDTM Columns
--=============================================================================================================================================
CREATE VIEW  [dbo].[vw_OutdoorWorkQueueSessionData]
AS
SELECT [dbo].[Configuration].[ValueTitle] AS WorkType,
[dbo].[Configuration].[Value] AS WorkTypeId,
[dbo].[Market].[Descrip] AS Market,
[dbo].[OccurrenceDetailODR].[DatePictureTaken] AS CaptureDate,
[dbo].[OccurrenceDetailODR].[ImageFileName],
NULL AS  TotalQScore,
[dbo].PatternStaging.[ScoreQ],
[dbo].[OccurrenceDetailODR].[MTMarketID] As MTMarketId,
[dbo].[Market].[MarketID],
[dbo].PatternStaging.[LanguageID], 
[dbo].[Language].[Description] As [Language],
[dbo].PatternStaging.[CreativeStgID],
[dbo].PatternStaging.[Query],
[dbo].PatternStaging.[Exception],
[dbo].[CreativeDetailStagingODR].[CreativeAssetName],
[dbo].[CreativeDetailStagingODR].[CreativeFileType],
[dbo].[CreativeDetailStagingODR].[CreativeFileSize],
--[dbo].[CreativeDetailsODRStg].[Format] AS CreativeDetailsODRStgFormat ,
[dbo].[OccurrenceDetailODR].[Advertiser],
[dbo].[ODRAdFormatMap].[FormatDescrip] AS [Format],
[dbo].[OccurrenceDetailODR].[OccurrenceDetailODRID] AS OccurrenceId,
[dbo].[OccurrenceDetailODR].[AdID] AS Adid,
PatternStaging.[PatternStagingID] AS PatternmasterStagingId,
PatternStaging.[AuditedByID],
PatternStaging.[AuditedDT]
from [dbo].[OccurrenceDetailODR]
INNER JOIN [Market] ON [Market].[MarketID]=[dbo].[OccurrenceDetailODR].[MTMarketID] 
INNER JOIN [dbo].PatternStaging ON PatternStaging.[CreativeSignature]=[dbo].[OccurrenceDetailODR].[ImageFileName]
INNER JOIN [dbo].[CreativeStaging] ON [dbo].[CreativeStaging].[CreativeStagingID]= [dbo].PatternStaging.[CreativeStgID]
INNER JOIN [dbo].[CreativeDetailStagingODR] ON [dbo].[CreativeDetailStagingODR].[CreativeStagingID]=[dbo].[CreativeStaging].[CreativeStagingID]
INNER JOIN  [dbo].[ODRAdFormatMap] ON [dbo].[ODRAdFormatMap].[MTFormatID]=[dbo].[OccurrenceDetailODR].[AdFormatID]
INNER JOIN [Language] ON [dbo].[Language].[LanguageID]=[dbo].PatternStaging.[LanguageID]
INNER JOIN [dbo].[Configuration] ON [dbo].[Configuration].[Value]=[dbo].[OccurrenceDetailODR].[WorkType] 
AND [dbo].[Configuration].[ComponentName]='WorkType'
and [dbo].[Configuration].Systemname='All'
												--Adding Adid and Patternmasterid Check
and [dbo].[OccurrenceDetailODR].[AdID] is  null
--and [dbo].[OccurrenceDetailODR].[PatternID] is  null