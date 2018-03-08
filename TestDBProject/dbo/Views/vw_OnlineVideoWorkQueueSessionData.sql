

-- =========================================================================

-- Author		: Ramesh Bangi 

-- Create date	: 09/18/2015

-- Description	: Get Session Data for Online Video Work Queue 

-- Execution	: SELECT *	FROM [vw_OnlineVideoWorkQueueSessionData]

-- Updated By	: 

--===========================================================================

CREATE VIEW  [dbo].[vw_OnlineVideoWorkQueueSessionData]

with schemabinding

as 

SELECT distinct [dbo].[OccurrenceDetailONV].[CreativeSignature]			AS CreativeSignature,

		[Configuration].valuetitle							    AS WorkType,		--[dbo].[PatternMasterStg].[WorkType]

		[dbo].[ScrapeSession].[ScrapeDate]							AS CaptureDate,

		' '					 										AS TotalQScore,		--[dbo].[PatternMasterStg].[ScoreQ]

		' '															AS Advertiser,

		[PatternStaging].ScoreQ										AS ScoreQ,						

		[OccurrenceDetailONV].[OccurrenceDetailONVID]				AS OccurrenceId,

		[PatternStaging].MediaOutlet								AS MediaOutlet,

		[dbo].[Language].[languageid]							AS [LanguageId],

		[dbo].[PatternStaging].[CreativeStgID]					AS CreativeMasterStagingId,

		[dbo].[PatternStaging].[MediaStream]						AS MediaStream,

		[dbo].[PatternStaging].[Exception]						AS IsException,

		[dbo].[PatternStaging].[Query]							AS IsQuery,

		[Configuration].value as worktypeID             

		

FROM dbo.[PatternStaging] 

INNER JOIN dbo.[OccurrenceDetailONV] ON dbo.[PatternStaging].[PatternStagingID]=dbo.[OccurrenceDetailONV].[PatternStagingID]

INNER JOIN dbo.[Language] ON dbo.[Language].[LanguageID]=dbo.[PatternStaging].[LanguageID] 

INNER JOIN dbo.[ScrapeSession] ON dbo.[ScrapeSession].[ScrapeSessionID]=dbo.[OccurrenceDetailONV].[ScrapeSessionID] 

inner join dbo.[Configuration] on  [PatternStaging].worktype=[Configuration].value and  Componentname='worktype' and Systemname='ALL'

AND ([PatternStaging].[Query] IS  NULL OR [PatternStaging].[Query]=0) AND ([PatternStaging].[Exception] IS  NULL OR [PatternStaging].[Exception]=0) 

inner join dbo.creativedetailstagingonv on dbo.creativedetailstagingonv.[CreativeStagingID]=dbo.[PatternStaging].[CreativeStgID]

and dbo.creativedetailstagingonv.creativedownloaded=1 and dbo.creativedetailstagingonv.filesize>0 and dbo.creativedetailstagingonv.creativefiletype='mp4'

and dbo.[PatternStaging].[CreativeStgID] is not null

and dbo.[PatternStaging].mediaStream='148'