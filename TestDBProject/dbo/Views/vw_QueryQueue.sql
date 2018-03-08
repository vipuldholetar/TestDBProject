


-- =============================================================================
-- Author		: Ramesh Bangi,Arun Nair  
-- Create date	: 7/29/2015
-- Description	: Gets Query Data 
-- Updated By	: Ramesh Bangi for Online Display
--				  Ramesh Bangi for Online Video
--				  Ramesh Bangi for Mobile on 10/13/2015
--				  Ramesh Bangi for Email on 10/29/2015
--				  Ramesh Bangi for Website on 11/05/2015
--				  Ramesh Bangi for Social on 11/18/2015
-- Execution	: Select * from [dbo].[vw_QueryQueue]
--===============================================================================


CREATE VIEW [dbo].[vw_QueryQueue]
AS
--------------------------------------------------------------------------------------------------------------------
Select(
Select  distinct valuetitle  From [dbo].[Configuration]
INNER JOIN  [dbo].[QueryDetail] ON [dbo].[QueryDetail].[MediaStreamID] = [dbo].[Configuration].Value AND 
[dbo].[Configuration].[SystemName]='All' and ComponentName='Media Stream' and value='TV') AS MediaStream,
 [dbo].[QueryDetail].[MediaStreamID] AS MediaStreamId,
[dbo].[PatternStaging].[CreativeSignature] As CreativeSignature,
'' AS OccurrenceId,
[Configuration].value as QueryCategoryID,
[Configuration].valuetitle as QueryCategory,
[dbo].[QueryDetail].QueryText,
[User].FName+ ' ' + [User].LName As RaisedBy,
[dbo].[QueryDetail].[QryRaisedOn] As RaisedOn,
[dbo].[QueryDetail].[QryAnswer] As Answer,
(select [user].FName + ' ' + [user].LName from [user] where userid=[dbo].[QueryDetail].QryAnsweredBy) As AnsweredBy,
[dbo].[QueryDetail].[QryAnsweredOn] As  AnsweredOn,
[dbo].[fn_CheckAnsweredOn]([dbo].[QueryDetail].[QryAnsweredOn],[dbo].[QueryDetail].[QryRaisedOn])  As Age,
[dbo].[PatternStaging].[PatternStagingID] AS KeyID,
[Language].LanguageId,
[Language].Description AS  [Language],
'' AS  Advertiser,
NULL AS AdvertiserId,
[dbo].[QueryDetail].[QueryID] AS QueryId,
[dbo].GetAssignedUserName([dbo].[QueryDetail].[AssignedToID]) AS AssignedTo, 
[dbo].[QueryDetail].[AssignedToID] as assignedtouserid,
[USER].UserID
From [dbo].[QueryDetail]
LEFT JOIN [dbo].[Configuration] ON [dbo].[Configuration].[Value]=[dbo].[QueryDetail].[QueryCategory] 
AND [dbo].[Configuration].[ComponentName]='Query Category' AND  [dbo].[Configuration].Systemname='All'
INNER  JOIN [dbo].[PatternStaging] ON [dbo].[QueryDetail].[PatternStgID] = [dbo].[PatternStaging].[PatternStagingID] AND 
[dbo].[PatternStaging].[Query] IS NOT NULL
LEFT JOIN [Language] ON [Language].LanguageId = [dbo].[PatternStaging].[LanguageID]
INNER JOIN [user] ON [user].[UserID]=[dbo].[QueryDetail].[QryRaisedBy]
AND  [dbo].[QueryDetail].[PatternMasterID] is null
AND [QueryDetail].[MediaStreamID]='TV'

UNION 

Select(
Select  distinct valuetitle  From [dbo].[Configuration]
INNER JOIN  [dbo].[QueryDetail] ON [dbo].[QueryDetail].[MediaStreamID] = [dbo].[Configuration].Value AND 
[dbo].[Configuration].[SystemName]='All' and ComponentName='Media Stream' and value='OD') AS MediaStream,
[dbo].[QueryDetail].[MediaStreamID] AS MediaStreamId,
[dbo].[PatternStaging].[CreativeSignature] As CreativeSignature,
'' AS OccurrenceId,
[Configuration].value as QueryCategoryID,
[Configuration].valuetitle as QueryCategory,
[dbo].[QueryDetail].QueryText,
[User].FName+ ' ' + [User].LName As RaisedBy,
[dbo].[QueryDetail].[QryRaisedOn] As RaisedOn,
[dbo].[QueryDetail].[QryAnswer] As Answer,
(select [user].FName + ' ' + [user].LName from [user] where userid=[dbo].[QueryDetail].QryAnsweredBy) As AnsweredBy,
[dbo].[QueryDetail].[QryAnsweredOn] As  AnsweredOn,
[dbo].[fn_CheckAnsweredOn]([dbo].[QueryDetail].[QryAnsweredOn],[dbo].[QueryDetail].[QryRaisedOn])  As Age,
[dbo].[PatternStaging] .[PatternStagingID] AS KeyID,
[Language].LanguageId,
[Language].Description AS  [Language],
'' AS  Advertiser,
NULL AS AdvertiserId,
[dbo].[QueryDetail].[QueryID] AS QueryId,
[dbo].GetAssignedUserName([dbo].[QueryDetail].[AssignedToID]) AS AssignedTo,
[dbo].[QueryDetail].[AssignedToID] as assignedtouserid,
[USER].UserID
From [dbo].[QueryDetail]
LEFT JOIN [dbo].[Configuration] ON [dbo].[Configuration].[Value]=[dbo].[QueryDetail].[QueryCategory] 
AND [dbo].[Configuration].[ComponentName]='Query Category' AND  [dbo].[Configuration].Systemname='All'
INNER  JOIN [dbo].[PatternStaging] ON [dbo].[QueryDetail].[PatternStgID] = [dbo].[PatternStaging].[PatternStagingID] AND 
[dbo].[PatternStaging].[Query] IS NOT NULL
INNER JOIN [Language] ON [Language].LanguageId = [dbo].[PatternStaging].[LanguageID]
INNER JOIN [user] ON [user].[UserID]=[dbo].[QueryDetail].[QryRaisedBy]
and  [dbo].[QueryDetail].[PatternMasterID] is null
AND [QueryDetail].[MediaStreamID]='OD'

UNION

Select(
Select  distinct valuetitle  From [dbo].[Configuration]
INNER JOIN  [dbo].[QueryDetail] ON [dbo].[QueryDetail].[MediaStreamID] = [dbo].[Configuration].Value AND 
[dbo].[Configuration].[SystemName]='All' and ComponentName='Media Stream' and value='CIN') AS MediaStream,
[dbo].[QueryDetail].[MediaStreamID] AS MediaStreamId,
[dbo].[PatternStaging].[CreativeSignature],
'' AS OccurrenceId,
[Configuration].value as QueryCategoryID,
[Configuration].valuetitle as QueryCategory,
[dbo].[QueryDetail].QueryText,
[User].FName+ ' ' + [User].LName As RaisedBy,
[dbo].[QueryDetail].[QryRaisedOn] As RaisedOn,
[dbo].[QueryDetail].[QryAnswer] As Answer,
(select [user].FName + ' ' + [user].LName from [user] where userid=[dbo].[QueryDetail].QryAnsweredBy) As AnsweredBy,
[dbo].[QueryDetail].[QryAnsweredOn] As  AnsweredOn,
[dbo].[fn_CheckAnsweredOn]([dbo].[QueryDetail].[QryAnsweredOn],[dbo].[QueryDetail].[QryRaisedOn])  As Age,
[dbo].[PatternStaging] .[PatternStagingID] AS KeyID,
[Language].LanguageId,
[Language].Description AS  [Language],
'' AS  Advertiser,
NULL AS AdvertiserId,
[dbo].[QueryDetail].[QueryID] AS QueryId,
[dbo].GetAssignedUserName([dbo].[QueryDetail].[AssignedToID]) AS AssignedTo,
[dbo].[QueryDetail].[AssignedToID] as assignedtouserid,
[USER].UserID
From [dbo].[QueryDetail]
left JOIN [dbo].[Configuration] ON [dbo].[Configuration].[Value]=[dbo].[QueryDetail].[QueryCategory] 
AND [dbo].[Configuration].[ComponentName]='Query Category' AND  [dbo].[Configuration].Systemname='All'
INNER  JOIN [dbo].[PatternStaging] ON [dbo].[QueryDetail].[PatternStgID] = [dbo].[PatternStaging].[PatternStagingID] AND 
[dbo].[PatternStaging].Query IS NOT NULL
INNER JOIN [Language] ON [Language].LanguageId = [dbo].[PatternStaging].[LanguageID]
INNER JOIN [user] ON [user].[UserID]=[dbo].[QueryDetail].[QryRaisedBy]
and  [dbo].[QueryDetail].[PatternMasterID] is null
AND [QueryDetail].[MediaStreamID]='CIN'
UNION 

Select(
Select  distinct valuetitle  From [dbo].[Configuration]
INNER JOIN  [dbo].[QueryDetail] ON [dbo].[QueryDetail].[MediaStreamID] = [dbo].[Configuration].Value AND 
[dbo].[Configuration].[SystemName]='All' and ComponentName='Media Stream' and value='RAD') AS MediaStream,
[dbo].[QueryDetail].[MediaStreamID] AS MediaStreamId,
[dbo].[PatternStaging].CreativeSignature,
'' AS OccurrenceId,
[Configuration].value as QueryCategoryID,
[Configuration].valuetitle as QueryCategory,
[dbo].[QueryDetail].QueryText,
[User].FName+ ' ' + [User].LName As RaisedBy,
[dbo].[QueryDetail].[QryRaisedOn] As RaisedOn,
[dbo].[QueryDetail].[QryAnswer] As Answer,
(select [user].FName + ' ' + [user].LName from [user] where userid=[dbo].[QueryDetail].QryAnsweredBy) As AnsweredBy,
[dbo].[QueryDetail].[QryAnsweredOn] As  AnsweredOn,
[dbo].[fn_CheckAnsweredOn]([dbo].[QueryDetail].[QryAnsweredOn],[dbo].[QueryDetail].[QryRaisedOn])  As Age,
[dbo].[PatternStaging].[PatternStagingID] AS KeyID,
[Language].LanguageId,
[Language].Description AS  [Language],
'' AS  Advertiser,
NULL AS AdvertiserId,
[dbo].[QueryDetail].[QueryID] AS QueryId,
[dbo].GetAssignedUserName([dbo].[QueryDetail].[AssignedToID]) AS AssignedTo,
[dbo].[QueryDetail].[AssignedToID] as assignedtouserid,
[USER].UserID
From [dbo].[QueryDetail]
inner JOIN [dbo].[Configuration] ON [dbo].[Configuration].[Value]=[dbo].[QueryDetail].[QueryCategory] 
AND [dbo].[Configuration].[ComponentName]='Query Category' AND   [dbo].[Configuration].Systemname='All'
left JOIN [PatternStaging] ON [PatternStaging].[PatternStagingID]= [dbo].[QueryDetail].[PatternStgID]
INNER JOIN [Language] on [Language].LanguageID=[PatternStaging].[LanguageID]
INNER JOIN [user] ON [user].[UserID]=[dbo].[QueryDetail].[QryRaisedBy]
AND ([PatternStaging].[Query] IS NOT Null)
and  [dbo].[QueryDetail].[PatternMasterID] is null
AND [QueryDetail].[MediaStreamID]='RAD'
UNION 

SELECT(
SELECT  DISTINCT valuetitle  From [dbo].[Configuration]
INNER JOIN  [dbo].[QueryDetail] ON [dbo].[QueryDetail].[MediaStreamID] = [dbo].[Configuration].Value AND 
[dbo].[Configuration].[SystemName]='All' and ComponentName='Media Stream' and value='CIR') AS MediaStream,
[dbo].[QueryDetail].[MediaStreamID] AS MediaStreamId,
Convert(NVARCHAR,[dbo].[OccurrenceDetailCIR].[OccurrenceDetailCIRID]) AS CreativeSignature,
[dbo].[OccurrenceDetailCIR].[OccurrenceDetailCIRID] AS OccurrenceId,
[Configuration].value as QueryCategoryID,
[Configuration].valuetitle as QueryCategory,
[dbo].[QueryDetail].QueryText,
[User].FName+ ' ' + [User].LName As RaisedBy,
[dbo].[QueryDetail].[QryRaisedOn] As RaisedOn,
[dbo].[QueryDetail].[QryAnswer] As Answer,
(select [user].FName + ' ' + [user].LName from [user] where userid=[dbo].[QueryDetail].QryAnsweredBy) As AnsweredBy,
[dbo].[QueryDetail].[QryAnsweredOn] As  AnsweredOn,
[dbo].[fn_CheckAnsweredOn]([dbo].[QueryDetail].[QryAnsweredOn],[dbo].[QueryDetail].[QryRaisedOn])  As Age,
[OccurrenceDetailCIR].[OccurrenceDetailCIRID] AS KeyID,
[Language].LanguageId,
[Language].Description AS  [Language],
'' AS  Advertiser,
NULL AS AdvertiserId,
[dbo].[QueryDetail].[QueryID] AS QueryId,
[dbo].GetAssignedUserName([dbo].[QueryDetail].[AssignedToID]) AS AssignedTo,
[dbo].[QueryDetail].[AssignedToID] as assignedtouserid,
[USER].UserID
From [dbo].[QueryDetail]
LEFT JOIN [dbo].[Configuration] ON [dbo].[Configuration].[Value]=[dbo].[QueryDetail].[QueryCategory] 
AND [dbo].[Configuration].[ComponentName]='Query Category' AND  [dbo].[Configuration].Systemname='All'
INNER JOIN [dbo].[OccurrenceDetailCIR] ON [dbo].[OccurrenceDetailCIR].[OccurrenceDetailCIRID]=[dbo].[QueryDetail].[OccurrenceID]
INNER JOIN [Language] on [Language].LanguageID=[dbo].[OccurrenceDetailCIR].[LanguageID]
INNER JOIN [user] ON [user].[UserID]=[dbo].[QueryDetail].[QryRaisedBy]
AND [dbo].[OccurrenceDetailCIR].[Query] IS NOT NULL AND [dbo].[OccurrenceDetailCIR].OccurrenceStatusID != 1
AND [dbo].[QueryDetail].[System]='I&O' AND [dbo].[QueryDetail].EntityLevel='OCC'  
AND [QueryDetail].[MediaStreamID]='CIR'
AND QueryDetail.OccurrenceId not in (select patternmasterstagingid from ExceptionDetail where MediaStream = 'CIR')
UNION 

SELECT(
SELECT  DISTINCT valuetitle  From [dbo].[Configuration]
INNER JOIN  [dbo].[QueryDetail] ON [dbo].[QueryDetail].[MediaStreamID] = [dbo].[Configuration].Value AND 
[dbo].[Configuration].[SystemName]='All' and ComponentName='Media Stream' and value='PUB') AS MediaStream,
[dbo].[QueryDetail].[MediaStreamID] AS MediaStreamId,
Convert(NVARCHAR,[dbo].[OccurrenceDetailPUB].[OccurrenceDetailPUBID]) AS CreativeSignature,
[dbo].[OccurrenceDetailPUB].[OccurrenceDetailPUBID] AS OccurrenceId,
[Configuration].value as QueryCategoryID,
[Configuration].valuetitle as QueryCategory,
[dbo].[QueryDetail].QueryText,
[User].FName+ ' ' + [User].LName As RaisedBy,
[dbo].[QueryDetail].[QryRaisedOn] As RaisedOn,
[dbo].[QueryDetail].[QryAnswer] As Answer,
(select [user].FName + ' ' + [user].LName from [user] where userid=[dbo].[QueryDetail].QryAnsweredBy) As AnsweredBy,
[dbo].[QueryDetail].[QryAnsweredOn] As  AnsweredOn,
[dbo].[fn_CheckAnsweredOn]([dbo].[QueryDetail].[QryAnsweredOn],[dbo].[QueryDetail].[QryRaisedOn])  As Age,
[dbo].[OccurrenceDetailPUB].[OccurrenceDetailPUBID] AS KeyID,
[Language].LanguageId,
[Language].Description AS  [Language],
'' AS  Advertiser,
NULL AS AdvertiserId,
[dbo].[QueryDetail].[QueryID] AS QueryId,
[dbo].GetAssignedUserName([dbo].[QueryDetail].[AssignedToID]) AS AssignedTo,
[dbo].[QueryDetail].[AssignedToID] as assignedtouserid,
[USER].UserID
From [dbo].[QueryDetail]
LEFT JOIN [dbo].[Configuration] ON [dbo].[Configuration].[Value]=[dbo].[QueryDetail].[QueryCategory] 
AND [dbo].[Configuration].[ComponentName]='Query Category' AND  [dbo].[Configuration].Systemname='All'
INNER JOIN [dbo].[OccurrenceDetailPUB] ON [dbo].[OccurrenceDetailPUB].[OccurrenceDetailPUBID]=[dbo].[QueryDetail].[OccurrenceID]
INNER JOIN [dbo].[Pubissue] ON [dbo].[Pubissue].[PubIssueID]=[dbo].[OccurrenceDetailPUB].[PubIssueID]
INNER JOIN [dbo].[PubEdition] ON [dbo].[PubEdition].[PubEditionID]=[dbo].[Pubissue].[PubEditionID]
INNER JOIN [dbo].[Language] ON [dbo].[Language].[LanguageID]=[dbo].[PubEdition].[LanguageID]
INNER JOIN [user] ON [user].[UserID]=[dbo].[QueryDetail].[QryRaisedBy]
AND [dbo].[OccurrenceDetailPUB] .[Query] IS NOT NULL AND [dbo].[OccurrenceDetailPUB].OccurrenceStatusID ! = 1
AND [dbo].[QueryDetail].[System]='I&O' AND [dbo].[QueryDetail].EntityLevel='OCC'  
AND [QueryDetail].[MediaStreamID]='PUB'

UNION


SELECT  'ISS' AS MediaStream,
[dbo].[QueryDetail].[MediaStreamID] AS MediaStreamId,
Convert(NVARCHAR,[dbo].[Pubissue].[PubIssueID]) AS CreativeSignature,
[dbo].[Pubissue].[PubIssueID] AS OccurrenceId,
[Configuration].value as QueryCategoryID,
[Configuration].valuetitle as QueryCategory,
[dbo].[QueryDetail].QueryText,
[User].FName+ ' ' + [User].LName As RaisedBy,
[dbo].[QueryDetail].[QryRaisedOn] As RaisedOn,
[dbo].[QueryDetail].[QryAnswer] As Answer,
(select [user].FName + ' ' + [user].LName from [user] where userid=[dbo].[QueryDetail].QryAnsweredBy) As AnsweredBy,
[dbo].[QueryDetail].[QryAnsweredOn] As  AnsweredOn,
[dbo].[fn_CheckAnsweredOn]([dbo].[QueryDetail].[QryAnsweredOn],[dbo].[QueryDetail].[QryRaisedOn])  As Age,
[dbo].[Pubissue].[PubIssueID] AS KeyID,
[dbo].[Language].LanguageId,
[dbo].[Language].[Description] AS  [Language],
'' AS  Advertiser,
NULL AS AdvertiserId,
[dbo].[QueryDetail].[QueryID] AS QueryId,
[dbo].GetAssignedUserName([dbo].[QueryDetail].[AssignedToID]) AS AssignedTo,
[dbo].[QueryDetail].[AssignedToID] as assignedtouserid,
[USER].UserID
From [dbo].[QueryDetail]
LEFT JOIN [dbo].[Configuration] ON [dbo].[Configuration].[Value]=[dbo].[QueryDetail].[QueryCategory] 
AND [dbo].[Configuration].[ComponentName]='Query Category' AND  [dbo].[Configuration].Systemname='All'
INNER JOIN [dbo].[Pubissue] ON [dbo].[Pubissue].[PubIssueID]=[dbo].[QueryDetail].[PubIssueID]
INNER JOIN [dbo].[PubEdition] ON [dbo].[PubEdition].[PubEditionID]=[dbo].[Pubissue].[PubEditionID]
INNER JOIN [dbo].[Language] ON [dbo].[Language].[LanguageID]=[dbo].[PubEdition].[LanguageID]
INNER JOIN [USER] ON [USER].[UserID]=[dbo].[QueryDetail].[QryRaisedBy]
AND [dbo].[Pubissue].IsQuery IS NOT NULL 
AND [dbo].[QueryDetail].[System]='I&O' AND [dbo].[QueryDetail].EntityLevel='PUB' 

UNION 

Select(
Select  distinct valuetitle  From [dbo].[Configuration]
INNER JOIN  [dbo].[QueryDetail] ON [dbo].[QueryDetail].[MediaStreamID] = [dbo].[Configuration].Value AND 
[dbo].[Configuration].[SystemName]='All' and ComponentName='Media Stream' and value='OND') AS MediaStream,
[dbo].[QueryDetail].[MediaStreamID] AS MediaStreamId,
[CreativeStaging].CreativeSignature As CreativeSignature,
'' AS OccurrenceId,
[Configuration].value as QueryCategoryID,
[Configuration].valuetitle as QueryCategory,
[dbo].[QueryDetail].QueryText,
[User].FName+ ' ' + [User].LName As RaisedBy,
[dbo].[QueryDetail].[QryRaisedOn] As RaisedOn,
[dbo].[QueryDetail].[QryAnswer] As Answer,
(select [user].FName + ' ' + [user].LName from [user] where userid=[dbo].[QueryDetail].QryAnsweredBy) As AnsweredBy,
[dbo].[QueryDetail].[QryAnsweredOn] As  AnsweredOn,
[dbo].[fn_CheckAnsweredOn]([dbo].[QueryDetail].[QryAnsweredOn],[dbo].[QueryDetail].[QryRaisedOn])  As Age,
[dbo].[PatternStaging] .[PatternStagingID] AS KeyID,
[Language].LanguageId,
[Language].Description AS  [Language],
'' AS  Advertiser,
NULL AS AdvertiserId,
[dbo].[QueryDetail].[QueryID] AS QueryId,
[dbo].GetAssignedUserName([dbo].[QueryDetail].[AssignedToID]) AS AssignedTo,
[dbo].[QueryDetail].[AssignedToID] as assignedtouserid,
[USER].UserID
From [dbo].[QueryDetail]
LEFT JOIN [dbo].[Configuration] ON [dbo].[Configuration].[Value]=[dbo].[QueryDetail].[QueryCategory] 
AND [dbo].[Configuration].[ComponentName]='Query Category' AND  [dbo].[Configuration].Systemname='All'
INNER  JOIN [dbo].[PatternStaging] ON [dbo].[QueryDetail].[PatternStgID] = [dbo].[PatternStaging].[PatternStagingID] AND 
[dbo].[PatternStaging].[Query] IS NOT NULL
INNER JOIN [Language] ON [Language].LanguageId = [dbo].[PatternStaging].[LanguageID]
INNER JOIN [user] ON [user].[UserID]=[dbo].[QueryDetail].[QryRaisedBy]
and  [dbo].[QueryDetail].[PatternMasterID] is null
AND [QueryDetail].[MediaStreamID]='OND'
inner join [CreativeStaging] on [CreativeStaging].[CreativeStagingID]=[PatternStaging].[CreativeStgID] 

UNION

Select(
Select  distinct valuetitle  From [dbo].[Configuration]
INNER JOIN  [dbo].[QueryDetail] ON [dbo].[QueryDetail].[MediaStreamID] = [dbo].[Configuration].Value AND 
[dbo].[Configuration].[SystemName]='All' and ComponentName='Media Stream' and value='ONV') AS MediaStream,
[dbo].[QueryDetail].[MediaStreamID] AS MediaStreamId,
[CreativeStaging].CreativeSignature As CreativeSignature,
'' AS OccurrenceId,
[Configuration].value as QueryCategoryID,
[Configuration].valuetitle as QueryCategory,
[dbo].[QueryDetail].QueryText,
[User].FName+ ' ' + [User].LName As RaisedBy,
[dbo].[QueryDetail].[QryRaisedOn] As RaisedOn,
[dbo].[QueryDetail].[QryAnswer] As Answer,
(select [user].FName + ' ' + [user].LName from [user] where userid=[dbo].[QueryDetail].QryAnsweredBy) As AnsweredBy,
[dbo].[QueryDetail].[QryAnsweredOn] As  AnsweredOn,
[dbo].[fn_CheckAnsweredOn]([dbo].[QueryDetail].[QryAnsweredOn],[dbo].[QueryDetail].[QryRaisedOn])  As Age,
[dbo].[PatternStaging] .[PatternStagingID] AS KeyID,
[Language].LanguageId,
[Language].Description AS  [Language],
'' AS  Advertiser,
NULL AS AdvertiserId,
[dbo].[QueryDetail].[QueryID] AS QueryId,
[dbo].GetAssignedUserName([dbo].[QueryDetail].[AssignedToID]) AS AssignedTo,
[dbo].[QueryDetail].[AssignedToID] as assignedtouserid,
[USER].UserID
From [dbo].[QueryDetail]
LEFT JOIN [dbo].[Configuration] ON [dbo].[Configuration].[Value]=[dbo].[QueryDetail].[QueryCategory] 
AND [dbo].[Configuration].[ComponentName]='Query Category' AND  [dbo].[Configuration].Systemname='All'
INNER  JOIN [dbo].[PatternStaging] ON [dbo].[QueryDetail].[PatternStgID] = [dbo].[PatternStaging].[PatternStagingID] AND 
[dbo].[PatternStaging].[Query] IS NOT NULL
INNER JOIN [Language] ON [Language].LanguageId = [dbo].[PatternStaging].[LanguageID]
INNER JOIN [user] ON [user].[UserID]=[dbo].[QueryDetail].[QryRaisedBy]
and  [dbo].[QueryDetail].[PatternMasterID] is null
AND [QueryDetail].[MediaStreamID]='ONV'
inner join [CreativeStaging] on [CreativeStaging].[CreativeStagingID]=[PatternStaging].[CreativeStgID] 

UNION

Select(
Select  distinct valuetitle  From [dbo].[Configuration]
INNER JOIN  [dbo].[QueryDetail] ON [dbo].[QueryDetail].[MediaStreamID] = [dbo].[Configuration].Value AND 
[dbo].[Configuration].[SystemName]='All' and ComponentName='Media Stream' and value='MOB') AS MediaStream,
[dbo].[QueryDetail].[MediaStreamID] AS MediaStreamId,
[CreativeStaging].CreativeSignature As CreativeSignature,
'' AS OccurrenceId,
[Configuration].value as QueryCategoryID,
[Configuration].valuetitle as QueryCategory,
[dbo].[QueryDetail].QueryText,
[User].FName+ ' ' + [User].LName As RaisedBy,
[dbo].[QueryDetail].[QryRaisedOn] As RaisedOn,
[dbo].[QueryDetail].[QryAnswer] As Answer,
(select [user].FName + ' ' + [user].LName from [user] where userid=[dbo].[QueryDetail].QryAnsweredBy) As AnsweredBy,
[dbo].[QueryDetail].[QryAnsweredOn] As  AnsweredOn,
[dbo].[fn_CheckAnsweredOn]([dbo].[QueryDetail].[QryAnsweredOn],[dbo].[QueryDetail].[QryRaisedOn])  As Age,
[dbo].[PatternStaging] .[PatternStagingID] AS KeyID,
[Language].LanguageId,
[Language].Description AS  [Language],
'' AS  Advertiser,
NULL AS AdvertiserId,
[dbo].[QueryDetail].[QueryID] AS QueryId,
[dbo].GetAssignedUserName([dbo].[QueryDetail].[AssignedToID]) AS AssignedTo,
[dbo].[QueryDetail].[AssignedToID] as assignedtouserid,
[USER].UserID
From [dbo].[QueryDetail]
LEFT JOIN [dbo].[Configuration] ON [dbo].[Configuration].[Value]=[dbo].[QueryDetail].[QueryCategory] 
AND [dbo].[Configuration].[ComponentName]='Query Category' AND  [dbo].[Configuration].Systemname='All'
INNER  JOIN [dbo].[PatternStaging] ON [dbo].[QueryDetail].[PatternStgID] = [dbo].[PatternStaging].[PatternStagingID] AND 
[dbo].[PatternStaging].[Query] IS NOT NULL
INNER JOIN [Language] ON [Language].LanguageId = [dbo].[PatternStaging].[LanguageID]
INNER JOIN [user] ON [user].[UserID]=[dbo].[QueryDetail].[QryRaisedBy]
and  [dbo].[QueryDetail].[PatternMasterID] is null
AND [QueryDetail].[MediaStreamID]='MOB'
inner join [CreativeStaging] on [CreativeStaging].[CreativeStagingID]=[PatternStaging].[CreativeStgID]

UNION

SELECT(
SELECT  DISTINCT valuetitle  From [dbo].[Configuration]
INNER JOIN  [dbo].[QueryDetail] ON [dbo].[QueryDetail].[MediaStreamID] = [dbo].[Configuration].Value AND 
[dbo].[Configuration].[SystemName]='All' and ComponentName='Media Stream' and value='EM') AS MediaStream,
[dbo].[QueryDetail].[MediaStreamID] AS MediaStreamId,
Convert(NVARCHAR,[dbo].[OccurrenceDetailEM].[OccurrenceDetailEMID]) AS CreativeSignature,
[dbo].[OccurrenceDetailEM].[OccurrenceDetailEMID] AS OccurrenceId,
[Configuration].value as QueryCategoryID,
[Configuration].valuetitle as QueryCategory,
[dbo].[QueryDetail].QueryText,
[User].FName+ ' ' + [User].LName As RaisedBy,
[dbo].[QueryDetail].[QryRaisedOn] As RaisedOn,
[dbo].[QueryDetail].[QryAnswer] As Answer,
(select [user].FName + ' ' + [user].LName from [user] where userid=[dbo].[QueryDetail].QryAnsweredBy) As AnsweredBy,
[dbo].[QueryDetail].[QryAnsweredOn] As  AnsweredOn,
[dbo].[fn_CheckAnsweredOn]([dbo].[QueryDetail].[QryAnsweredOn],[dbo].[QueryDetail].[QryRaisedOn])  As Age,
[OccurrenceDetailEM].[OccurrenceDetailEMID] AS KeyID,
1 AS LanguageId,
'English' As [Language],
'' AS  Advertiser,
NULL AS AdvertiserId,
[dbo].[QueryDetail].[QueryID] AS QueryId,
[dbo].GetAssignedUserName([dbo].[QueryDetail].[AssignedToID]) AS AssignedTo,
[dbo].[QueryDetail].[AssignedToID] as assignedtouserid,
[USER].UserID
From [dbo].[QueryDetail]
LEFT JOIN [dbo].[Configuration] ON [dbo].[Configuration].[Value]=[dbo].[QueryDetail].[QueryCategory] 
AND [dbo].[Configuration].[ComponentName]='Query Category' AND  [dbo].[Configuration].Systemname='All'
INNER JOIN [dbo].[OccurrenceDetailEM] ON [dbo].[OccurrenceDetailEM].[OccurrenceDetailEMID]=[dbo].[QueryDetail].[OccurrenceID]
--INNER JOIN languagemaster on languagemaster.LanguageID=[dbo].[OccurrenceDetailsEM].FK_LanguageID
INNER JOIN [user] ON [user].[UserID]=[dbo].[QueryDetail].[QryRaisedBy]
AND [dbo].[OccurrenceDetailEM].[Query] IS NOT NULL AND [dbo].[OccurrenceDetailEM].OccurrenceStatusID ! = 1
AND [dbo].[QueryDetail].[System]='I&O' AND [dbo].[QueryDetail].EntityLevel='OCC'  
AND [QueryDetail].[MediaStreamID]='EM' 

UNION

SELECT(
SELECT  DISTINCT valuetitle  From [dbo].[Configuration]
INNER JOIN  [dbo].[QueryDetail] ON [dbo].[QueryDetail].[MediaStreamID] = [dbo].[Configuration].Value AND 
[dbo].[Configuration].[SystemName]='All' and ComponentName='Media Stream' and value='WEB') AS MediaStream,
[dbo].[QueryDetail].[MediaStreamID] AS MediaStreamId,
Convert(NVARCHAR,[dbo].[OccurrenceDetailWEB].[OccurrenceDetailWEBID]) AS CreativeSignature,
[dbo].[OccurrenceDetailWEB].[OccurrenceDetailWEBID] AS OccurrenceId,
[Configuration].value as QueryCategoryID,
[Configuration].valuetitle as QueryCategory,
[dbo].[QueryDetail].QueryText,
[User].FName+ ' ' + [User].LName As RaisedBy,
[dbo].[QueryDetail].[QryRaisedOn] As RaisedOn,
[dbo].[QueryDetail].[QryAnswer] As Answer,
(select [user].FName + ' ' + [user].LName from [user] where userid=[dbo].[QueryDetail].QryAnsweredBy) As AnsweredBy,
[dbo].[QueryDetail].[QryAnsweredOn] As  AnsweredOn,
[dbo].[fn_CheckAnsweredOn]([dbo].[QueryDetail].[QryAnsweredOn],[dbo].[QueryDetail].[QryRaisedOn])  As Age,
[OccurrenceDetailWEB].[OccurrenceDetailWEBID] AS KeyID,
1 AS LanguageId,
'English' As [Language],
'' AS  Advertiser,
NULL AS AdvertiserId,
[dbo].[QueryDetail].[QueryID] AS QueryId,
[dbo].GetAssignedUserName([dbo].[QueryDetail].[AssignedToID]) AS AssignedTo,
[dbo].[QueryDetail].[AssignedToID] as assignedtouserid,
[USER].UserID
From [dbo].[QueryDetail]
LEFT JOIN [dbo].[Configuration] ON [dbo].[Configuration].[Value]=[dbo].[QueryDetail].[QueryCategory] 
AND [dbo].[Configuration].[ComponentName]='Query Category' AND  [dbo].[Configuration].Systemname='All'
INNER JOIN [dbo].[OccurrenceDetailWEB] ON [dbo].[OccurrenceDetailWEB].[OccurrenceDetailWEBID]=[dbo].[QueryDetail].[OccurrenceID]
--INNER JOIN languagemaster on languagemaster.LanguageID=[dbo].[OccurrenceDetailsEM].FK_LanguageID
INNER JOIN [user] ON [user].[UserID]=[dbo].[QueryDetail].[QryRaisedBy]
AND [dbo].[OccurrenceDetailWEB].[Query] IS NOT NULL AND [dbo].[OccurrenceDetailWEB].OccurrenceStatusID ! = 1
AND [dbo].[QueryDetail].[System]='I&O' AND [dbo].[QueryDetail].EntityLevel='OCC'  
AND [QueryDetail].[MediaStreamID]='WEB' 


UNION

SELECT(
SELECT  DISTINCT valuetitle  From [dbo].[Configuration]
INNER JOIN  [dbo].[QueryDetail] ON [dbo].[QueryDetail].[MediaStreamID] = [dbo].[Configuration].Value AND 
[dbo].[Configuration].[SystemName]='All' and ComponentName='Media Stream' and value='SOC') AS MediaStream,
[dbo].[QueryDetail].[MediaStreamID] AS MediaStreamId,
Convert(NVARCHAR,[dbo].[OccurrenceDetailSOC].[OccurrenceDetailSOCID]) AS CreativeSignature,
[dbo].[OccurrenceDetailSOC].[OccurrenceDetailSOCID] AS OccurrenceId,
[Configuration].value as QueryCategoryID,
[Configuration].valuetitle as QueryCategory,
[dbo].[QueryDetail].QueryText,
[User].FName+ ' ' + [User].LName As RaisedBy,
[dbo].[QueryDetail].[QryRaisedOn] As RaisedOn,
[dbo].[QueryDetail].[QryAnswer] As Answer,
(select [user].FName + ' ' + [user].LName from [user] where userid=[dbo].[QueryDetail].QryAnsweredBy) As AnsweredBy,
[dbo].[QueryDetail].[QryAnsweredOn] As  AnsweredOn,
[dbo].[fn_CheckAnsweredOn]([dbo].[QueryDetail].[QryAnsweredOn],[dbo].[QueryDetail].[QryRaisedOn])  As Age,
[OccurrenceDetailSOC].[OccurrenceDetailSOCID] AS KeyID,
1 AS LanguageId,
'English' As [Language],
'' AS  Advertiser,
NULL AS AdvertiserId,
[dbo].[QueryDetail].[QueryID] AS QueryId,
[dbo].GetAssignedUserName([dbo].[QueryDetail].[AssignedToID]) AS AssignedTo,
[dbo].[QueryDetail].[AssignedToID] as assignedtouserid,
[USER].UserID
From [dbo].[QueryDetail]
LEFT JOIN [dbo].[Configuration] ON [dbo].[Configuration].[Value]=[dbo].[QueryDetail].[QueryCategory] 
AND [dbo].[Configuration].[ComponentName]='Query Category' AND  [dbo].[Configuration].Systemname='All'
INNER JOIN [dbo].[OccurrenceDetailSOC] ON [dbo].[OccurrenceDetailSOC].[OccurrenceDetailSOCID]=[dbo].[QueryDetail].[OccurrenceID]
--INNER JOIN languagemaster on languagemaster.LanguageID=[dbo].[OccurrenceDetailsEM].FK_LanguageID
INNER JOIN [user] ON [user].[UserID]=[dbo].[QueryDetail].[QryRaisedBy]
AND [dbo].[OccurrenceDetailSOC].[Query] IS NOT NULL AND [dbo].[OccurrenceDetailSOC].OccurrenceStatusID ! = 1
AND [dbo].[QueryDetail].[System]='I&O' AND [dbo].[QueryDetail].EntityLevel='OCC'  
AND [QueryDetail].[MediaStreamID]='SOC' 

--AND [dbo].[QueryDetails].[QueryAnswer] IS NULL