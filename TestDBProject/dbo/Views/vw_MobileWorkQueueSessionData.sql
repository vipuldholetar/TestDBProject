
-- ===================================================================================================================

-- Author		: Ramesh Bangi 

-- Create date	: 09/30/2015

-- Description	: Get Session Data for Mobile Work Queue 

-- Execution	: SELECT count(*)	FROM OneMT.dbo.[vw_MobileWorkQueueSessionData] WHERE CREATIVESIGNATURE='e31c9240ec1f3904a51aef1042035f362787baea'

-- Updated By	: Arun Nair on 10/19/2015 - Add [CreativeDetailStagingMOB]creativedownloaded,filesize

--				: Karunakar on 10/20/2015 - Commenting  Creative File Type Check for Mobile

--====================================================================================================================

CREATE VIEW  [dbo].[vw_MobileWorkQueueSessionData]

with schemabinding

as 

SELECT  [dbo].[OccurrenceDetailMOB].[CreativeSignature]			AS CreativeSignature,

		[Configuration].valuetitle							    AS WorkType,		--[dbo].[PatternMasterStg].[WorkType]

		FORMAT (MobileCaptureSession.[CaptureStartDT], 'MM-dd-yy') 						AS CaptureDate,

		' '					 										AS TotalQScore,		--[dbo].[PatternMasterStg].[ScoreQ]

		' '															AS Advertiser,

		[PatternStaging].ScoreQ										AS ScoreQ,						

		[OccurrenceDetailMOB].[OccurrenceDetailMOBID]				AS OccurrenceId,

		[PatternStaging].MediaOutlet								AS MediaOutlet,

		[dbo].[Language].[languageid]							AS [LanguageId],

		[dbo].[PatternStaging].[CreativeStgID]					AS CreativeMasterStagingId,

		[dbo].[PatternStaging].[MediaStream]						AS MediaStream,

		[dbo].[PatternStaging].[Exception]						AS IsException,

		[dbo].[PatternStaging].[Query]							AS IsQuery,

		[Configuration].value as worktypeID             

		

FROM dbo.[PatternStaging] 

INNER JOIN dbo.[OccurrenceDetailMOB] ON dbo.[PatternStaging].[PatternStagingID]=dbo.[OccurrenceDetailMOB].[PatternStagingID]

INNER JOIN dbo.[Language] ON dbo.[Language].[LanguageID]=dbo.[PatternStaging].[LanguageID] 

INNER JOIN dbo.[MobileCaptureSession] ON dbo.[MobileCaptureSession].[MobileCaptureSessionID]=dbo.[OccurrenceDetailMOB].[CaptureSessionID] 

INNER JOIN dbo.[Configuration] on  [PatternStaging].worktype=[Configuration].value and  Componentname='worktype' and Systemname='ALL'

INNER JOIN [dbo].[CreativeDetailStagingMOB] on [dbo].[CreativeDetailStagingMOB].[CreativeStagingID]=dbo.[PatternStaging].[CreativeStgID]

where ([PatternStaging].[Query] IS  NULL OR [PatternStaging].[Query]=0) AND ([PatternStaging].[Exception] IS  NULL OR [PatternStaging].[Exception]=0) 

and [dbo].[PatternStaging].[CreativeStgID] is not null

AND [dbo].[CreativeDetailStagingMOB].creativedownloaded=1 

AND [dbo].[CreativeDetailStagingMOB].filesize>0

AND (isnumeric([PatternStaging].mediastream) = 1 and [PatternStaging].mediastream=(select configurationid from dbo.[Configuration] where componentname='Media stream' and value='MOB'))