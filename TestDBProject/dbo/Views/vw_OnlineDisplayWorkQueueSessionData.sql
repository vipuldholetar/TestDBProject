

CREATE VIEW  [dbo].[vw_OnlineDisplayWorkQueueSessionData]
WITH SCHEMABINDING
AS 
SELECT  distinct [dbo].[OccurrenceDetailOND].[CreativeSignature]	AS CreativeSignature,
		[Configuration].valuetitle							    AS WorkType,		--[dbo].[PatternMasterStg].[WorkType]
		[dbo].[ScrapeSession].[ScrapeDate]							AS CaptureDate,
		'NA'														AS TotalQScore,		--[dbo].[PatternMasterStg].[ScoreQ]
		' '															AS Advertiser,
		[PatternStaging].ScoreQ										AS ScoreQ,						
		[OccurrenceDetailOND].[OccurrenceDetailONDID]				AS OccurrenceId,
		[PatternStaging].MediaOutlet								AS MediaOutlet,
		[dbo].[Website].[WebsiteID]								AS WebSiteId,
		[dbo].[Language].[languageid]							AS [LanguageId],
		[dbo].[PatternStaging].[CreativeStgID]					AS CreativeMasterStagingId,
		[dbo].[PatternStaging].[MediaStream]						AS MediaStream,
		[dbo].[PatternStaging].[Exception]						AS IsException,
		[dbo].[PatternStaging].[Query]							AS IsQuery,
		[Configuration].value as worktypeID,
		[PatternStaging].[AuditedByID],
		[PatternStaging].[AuditedDT]
		--''														AS RichMedia    
FROM dbo.[PatternStaging] 
INNER  JOIN dbo.[OccurrenceDetailOND] ON dbo.[PatternStaging].[PatternStagingID]=dbo.[OccurrenceDetailOND].[PatternStagingID]
INNER JOIN dbo.[Language] ON dbo.[Language].[LanguageID]=dbo.[PatternStaging].[LanguageID] 
INNER JOIN dbo.[ScrapeSession] ON dbo.[ScrapeSession].[ScrapeSessionID]=dbo.[OccurrenceDetailOND].[ScrapeSessionID] 
INNER JOIN dbo.[WebSite] ON dbo.[WebSite].[WebsiteID]= dbo.[ScrapeSession].[WebsiteID] 
inner join dbo.creativedetailstagingond ON dbo.creativedetailstagingond.[CreativeStagingID]=dbo.[PatternStaging].[CreativeStgID]
inner join dbo.[Configuration] ON  [PatternStaging].worktype=[Configuration].value and  Componentname='worktype' and Systemname='ALL'
WHERE ([PatternStaging].[Query] IS  NULL OR [PatternStaging].[Query]<>1) 
AND ([PatternStaging].[Exception] IS  NULL OR [PatternStaging].[Exception]<>1) 
and [PatternStaging].mediastream='147'
and dbo.creativedetailstagingond.creativedownloaded=1 and dbo.creativedetailstagingond.filesize>0 and dbo.creativedetailstagingond.creativefiletype='jpg'
and dbo.[PatternStaging].[CreativeStgID] is not null