



-- =======================================================================================
-- Author			: Arun Nair 
-- Create date		: 07/14/2015
-- Description		: Get Session Data for Cinema Work Queue 
-- Execution		: [dbo].[vw_CinemaWorkQueueSessionData]
-- Updated By		: Ramesh On 08/12/2015  - CleanUp for OneMTDB 
--					  Arun Nair on 11/24/2015 - Added AuditBy,AuditDTM Columns					  
--=========================================================================================

CREATE VIEW [dbo].[vw_CinemaWorkQueueSessionData]
 
AS
SELECT
[dbo].[OccurrenceDetailCIN].[CreativeID] as CreativeSignature,
 [dbo].[Configuration].[ValueTitle] AS WorkType,
[dbo].[Configuration].[Value] AS WorkTypeId,
[dbo].[Market].[Descrip] AS MarketDescription,
[dbo].[PatternStaging].[ScoreQ] as [TotalQScore],
[dbo].[PatternStaging].[ScoreQ],
[dbo].[PatternStaging].[Query] as IsQuery,
[dbo].[PatternStaging].[Exception] as IsException,
[dbo].[PatternStaging].[CreativeStgID] AS CreativeMasterStagingID,
[dbo].[PatternStaging].[LanguageID],
[dbo].[PatternStaging].[CreatedDT] as CreateDTM,
[dbo].[Market].[MarketID] AS MarketId,
[dbo].[OccurrenceDetailCIN].[AirDT],
[dbo].[OccurrenceDetailCIN].[Customer],
[dbo].[OccurrenceDetailCIN].[Rating],
[dbo].[OccurrenceDetailCIN].[AdID],
[dbo].[OccurrenceDetailCIN].[PatternID],
[dbo].[OccurrenceDetailCIN].[OccurrenceDetailCINID] AS OccurrenceId,
[dbo].[PatternStaging].[PatternStagingID] As PatternMasterstagingId ,
[dbo].[CreativeDetailStagingCIN].[CreativeFileType],
[dbo].[CreativeDetailStagingCIN].[CreativeRepository],
[dbo].[CreativeDetailStagingCIN].[CreativeAssetName],
[dbo].[CreativeDetailStagingCIN].[CreativeFileSize], 
[dbo].[PatternStaging].AuditedByID as AuditBy,
[dbo].[PatternStaging].AuditedDT as AuditDTM
FROM [dbo].[OccurrenceDetailCIN]
INNER JOIN [dbo].[PatternStaging] ON [dbo].[PatternStaging].[CreativeSignature]=[dbo].[OccurrenceDetailCIN].[CreativeID]
INNER JOIN [dbo].[CreativeDetailStagingCIN] ON [dbo].[CreativeDetailStagingCIN].[CreativeStagingID]=[dbo].[PatternStaging].[CreativeStgID]
INNER JOIN [dbo].[Market] ON [dbo].[Market].[MarketID]=[dbo].[OccurrenceDetailCIN].[MarketID] 
INNER JOIN [dbo].[Configuration] ON [dbo].[Configuration].[Value]=[dbo].[OccurrenceDetailCIN].[WorkType] 
AND [dbo].[Configuration].[ComponentName]='WorkType' AND  [dbo].[Configuration].Systemname='All' 
WHERE [dbo].[OccurrenceDetailCIN].[AdID] is  null
AND [dbo].[OccurrenceDetailCIN].[PatternID] is  null