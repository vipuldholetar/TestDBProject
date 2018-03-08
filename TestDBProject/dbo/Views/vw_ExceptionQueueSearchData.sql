

-- =============================================================================
-- Author		: Ramesh Bangi,Arun Nair  
-- Create date	: 7/29/2015
-- Description	: Get Exception Data 
-- Updated By	: Ramesh Bangi for Online Display
--				: Karunakar on  12th Oct 2015,Adding Mobile Mediastream in Exception Queue Search
--				: Karunakar on  14th December 2015,Adding ExceptionStatus Alternate Creative Requested Check into Radio and Television
-- Execution	: Select * from [dbo].[vw_ExceptionQueueSearchData]
--===============================================================================







CREATE VIEW [dbo].[vw_ExceptionQueueSearchData]
AS







     -------------------------------------------------------------Unindexed Records--------------------------------------------------------------------------------------------



     SELECT ROW_NUMBER() OVER
                             (PARTITION BY [dbo].[PatternStaging].[PatternStagingID] ORDER BY [ExceptionDetail].[ExceptionDetailID] DESC
                             ) AS validrows,
                                             (
                                              SELECT DISTINCT
                                                     valuetitle
                                              FROM [dbo].[Configuration] INNER JOIN [dbo].[ExceptionDetail] ON [dbo].[ExceptionDetail].[MediaStream]
                                              = [dbo].[Configuration].[Value]
                                                                                                               AND
                                                                                                               [dbo].[Configuration].[SystemName] =
                                                                                                               'All'
                                                                                                               AND
                                                                                                               ComponentName = 'Media Stream'
                                                                                                               AND
                                                                                                               value = 'CIN'
                                             ) AS MediaStream, [dbo].[ExceptionDetail].[MediaStream] AS [MediaStreamId], [dbo].[PatternStaging].
                                             [CreativeSignature] AS CreativeSignature, '' AS adid, '' AS OccurrenceId, [dbo].[Configuration].
                                             [ValueTitle] AS ExceptionType, [dbo].[ExceptionDetail].[ExceptionStatus] AS ExceptionStatus, [user].
                                             FName+' '+[user].LName AS RaisedBy, CAST([ExceptionDetail].[ExcRaisedOn] AS DATE
                                                                                     ) AS RaisedOn, [dbo].GetAssignedUserName
            ([dbo].[ExceptionDetail].[AssignedToID]
            ) AS AssignedTo, CONVERT(NVARCHAR(MAX), DATEDIFF(day, [dbo].[ExceptionDetail].[ExcRaisedOn], GETDATE())
                                    ) AS Age, [dbo].[PatternStaging].[PatternStagingID] AS KeyID, [dbo].[ExceptionDetail].[ExceptionDetailID]
                                    AS ExceptionID, [PatternStaging].[LanguageID], NULL AS AdvertiserID, [Language].description AS LanguageName,
                                    '' AS Advertiser, [USER].UserID, [ExceptionDetail].[AssignedToID] AS assignedtouserid
     FROM [dbo].[ExceptionDetail] LEFT JOIN [dbo].[Configuration] ON [dbo].[Configuration].[Value] = [dbo].[ExceptionDetail].[ExceptionType]
                                                                     AND
                                                                     [dbo].[Configuration].[ComponentName] = 'Exception Type'
                                                                     AND
                                                                     [dbo].[Configuration].Systemname = 'All'
                                  INNER JOIN [PatternStaging] ON [PatternStaging].[PatternStagingID] = [ExceptionDetail].
                                  [PatternMasterStagingID]
                                  INNER JOIN [Language] ON [Language].LanguageID = [PatternStaging].[LanguageID]
                                  INNER JOIN [USER] ON [USER].[UserID] = [dbo].[ExceptionDetail].[ExcRaisedBy]
                                                       AND
                                                       ([PatternStaging].Exception IS NOT NULL)
                                                       AND
                                                       [dbo].[ExceptionDetail].[MediaStream] = 'CIN'
     UNION
     SELECT ROW_NUMBER() OVER
                             (PARTITION BY [dbo].[PatternStaging].[PatternStagingID] ORDER BY [ExceptionDetail].[ExceptionDetailID] DESC
                             ) AS validrows,
                                             (
                                              SELECT DISTINCT
                                                     valuetitle
                                              FROM [dbo].[Configuration] INNER JOIN [dbo].[ExceptionDetail] ON [dbo].[ExceptionDetail].[MediaStream]
                                              = [dbo].[Configuration].[Value]
                                                                                                               AND
                                                                                                               [dbo].[Configuration].[SystemName] =
                                                                                                               'All'
                                                                                                               AND
                                                                                                               ComponentName = 'Media Stream'
                                                                                                               AND
                                                                                                               value = 'CIR'
                                             ) AS MediaStream, [dbo].[ExceptionDetail].[MediaStream] AS [MediaStreamId], '' AS CreativeSignature,
                                             OccurrenceDetailCIR.adid AS adid, QueryDetail.OccurrenceId AS OccurrenceId, [dbo].[Configuration].
                                             [ValueTitle] AS ExceptionType, [dbo].[ExceptionDetail].[ExceptionStatus] AS ExceptionStatus, [user].
                                             FName+' '+[user].LName AS RaisedBy, CAST([ExceptionDetail].[ExcRaisedOn] AS DATE
                                                                                     ) AS RaisedOn, [dbo].GetAssignedUserName
            ([dbo].[ExceptionDetail].[AssignedToID]
            ) AS AssignedTo, CONVERT(NVARCHAR(MAX), DATEDIFF(day, [dbo].[ExceptionDetail].[ExcRaisedOn], GETDATE())
                                    ) AS Age, [dbo].[PatternStaging].[PatternStagingID] AS KeyID, [dbo].[ExceptionDetail].[ExceptionDetailID] AS
                                    ExceptionID, [PatternStaging].[LanguageID], NULL AS AdvertiserID, [Language].description AS LanguageName, '' AS
                                    Advertiser, [USER].UserID, [ExceptionDetail].[AssignedToID] AS assignedtouserid
     FROM [dbo].[ExceptionDetail] LEFT JOIN [dbo].[Configuration] ON [dbo].[Configuration].[Value] = [dbo].[ExceptionDetail].[ExceptionType]
                                                                     AND
                                                                     [dbo].[Configuration].[ComponentName] = 'Exception Type'
                                                                     AND
                                                                     [dbo].[Configuration].Systemname = 'All'
                                  INNER JOIN [PatternStaging] ON [PatternStaging].[PatternStagingID] = [ExceptionDetail].[PatternMasterStagingID]
                                  INNER JOIN [Language] ON [Language].LanguageID = [PatternStaging].[LanguageID]
                                  INNER JOIN [user] ON [user].[UserID] = [dbo].[ExceptionDetail].[ExcRaisedBy]
                                  INNER JOIN QueryDetail ON QueryDetail.OccurrenceID = [ExceptionDetail].[PatternMasterStagingID]
                                  INNER JOIN OccurrenceDetailCIR ON OccurrenceDetailCIR.OccurrenceDetailCIRID = QueryDetail.OccurrenceID
                                                                    --AND ([PatternStaging].[Exception] IS NOT Null) 
                                                                    AND
                                                                    [dbo].[ExceptionDetail].[MediaStream] = 'CIR'
                                                                    AND
                                                                    occurrencedetailcir.adid IS NOT NULL
     UNION
     SELECT ROW_NUMBER() OVER
                             (PARTITION BY [dbo].[PatternStaging].[PatternStagingID] ORDER BY [ExceptionDetail].[ExceptionDetailID] DESC
                             ) AS validrows,
                                             (
                                              SELECT DISTINCT
                                                     valuetitle
                                              FROM [dbo].[Configuration] INNER JOIN [dbo].[ExceptionDetail] ON [dbo].[ExceptionDetail].[MediaStream]
                                              = [dbo].[Configuration].[Value]
                                                                                                               AND
                                                                                                               [dbo].[Configuration].[SystemName] =
                                                                                                               'All'
                                                                                                               AND
                                                                                                               ComponentName = 'Media Stream'
                                                                                                               AND
                                                                                                               value = 'TV'
                                             ) AS MediaStream, [dbo].[ExceptionDetail].[MediaStream] AS [MediaStreamId], [dbo].[PatternStaging].
                                             [CreativeSignature] AS CreativeSignature, '' AS adid, '' AS OccurrenceId, [dbo].[Configuration].
                                             [ValueTitle] AS ExceptionType, [dbo].[ExceptionDetail].[ExceptionStatus] AS ExceptionStatus, [user].
                                             FName+' '+[user].LName AS RaisedBy, CAST([ExceptionDetail].[ExcRaisedOn] AS DATE
                                                                                     ) AS RaisedOn, [dbo].GetAssignedUserName
            ([dbo].[ExceptionDetail].[AssignedToID]
            ) AS AssignedTo, CONVERT(NVARCHAR(MAX), DATEDIFF(day, [dbo].[ExceptionDetail].[ExcRaisedOn], GETDATE())
                                    ) AS Age, [dbo].[PatternStaging].[PatternStagingID] AS KeyID, [dbo].[ExceptionDetail].[ExceptionDetailID] AS
                                    ExceptionID, [PatternStaging].[LanguageID], NULL AS AdvertiserID, [Language].description AS LanguageName, '' AS
                                    Advertiser, [USER].UserID, [ExceptionDetail].[AssignedToID] AS assignedtouserid
     FROM [dbo].[ExceptionDetail] LEFT JOIN [dbo].[Configuration] ON [dbo].[Configuration].[Value] = [dbo].[ExceptionDetail].[ExceptionType]
                                                                     AND
                                                                     [dbo].[Configuration].[ComponentName] = 'Exception Type'
                                                                     AND
                                                                     [dbo].[Configuration].Systemname = 'All'
                                  INNER JOIN [PatternStaging] ON [PatternStaging].[PatternStagingID] = [ExceptionDetail].
                                  [PatternMasterStagingID]
                                  INNER JOIN [Language] ON [Language].LanguageID = [PatternStaging].[LanguageID]
                                  INNER JOIN [user] ON [user].[UserID] = [dbo].[ExceptionDetail].[ExcRaisedBy]
                                                       AND
                                                       ([PatternStaging].[Exception] IS NOT NULL)
                                                       AND
                                                       [dbo].[ExceptionDetail].[MediaStream] = 'TV'
     UNION
     SELECT ROW_NUMBER() OVER
                             (PARTITION BY [dbo].[PatternStaging].[PatternStagingID] ORDER BY [ExceptionDetail].[ExceptionDetailID] DESC
                             ) AS validrows,
                                             (
                                              SELECT DISTINCT
                                                     valuetitle
                                              FROM [dbo].[Configuration] INNER JOIN [dbo].[ExceptionDetail] ON [dbo].[ExceptionDetail].[MediaStream]
                                              = [dbo].[Configuration].[Value]
                                                                                                               AND
                                                                                                               [dbo].[Configuration].[SystemName] =
                                                                                                               'All'
                                                                                                               AND
                                                                                                               ComponentName = 'Media Stream'
                                                                                                               AND
                                                                                                               value = 'RAD'
                                             ) AS MediaStream, [dbo].[ExceptionDetail].[MediaStream] AS [MediaStreamId], [dbo].[PatternStaging].
                                             CreativeSignature, '' AS adid, '' AS OccurrenceId, [dbo].[Configuration].[ValueTitle] AS ExceptionType,
                                             [dbo].[ExceptionDetail].[ExceptionStatus] AS ExceptionStatus, [user].FName+' '+[user].LName AS RaisedBy,
                                             CAST([ExceptionDetail].[ExcRaisedOn] AS DATE
                                                 ) AS RaisedOn, [dbo].GetAssignedUserName
            ([dbo].[ExceptionDetail].[AssignedToID]
            ) AS AssignedTo, CONVERT(NVARCHAR(MAX), DATEDIFF(day, [dbo].[ExceptionDetail].[ExcRaisedOn], GETDATE())
                                    ) AS Age, [dbo].[PatternStaging].[PatternStagingID] AS KeyID, [dbo].[ExceptionDetail].[ExceptionDetailID] AS
                                    ExceptionID, [PatternStaging].[LanguageID], NULL AS AdvertiserID, [Language].description AS LanguageName, '' AS
                                    Advertiser, [USER].UserID, [ExceptionDetail].[AssignedToID] AS assignedtouserid
     FROM [dbo].[ExceptionDetail] LEFT JOIN [dbo].[Configuration] ON [dbo].[Configuration].[Value] = [dbo].[ExceptionDetail].[ExceptionType]
                                                                     AND
                                                                     [dbo].[Configuration].[ComponentName] = 'Exception Type'
                                                                     AND
                                                                     [dbo].[Configuration].Systemname = 'All'
                                  INNER JOIN [PatternStaging] ON [PatternStaging].[PatternStagingID] = [ExceptionDetail].[PatternMasterStagingID]
                                  INNER JOIN [Language] ON [Language].LanguageID = [PatternStaging].[LanguageID]
                                  INNER JOIN [user] ON [user].[UserID] = [dbo].[ExceptionDetail].[ExcRaisedBy]
                                                       AND
                                                       ([PatternStaging].[Exception] IS NOT NULL)
                                                       AND
                                                       [dbo].[ExceptionDetail].[MediaStream] = 'RAD'
     UNION
     SELECT ROW_NUMBER() OVER
                             (PARTITION BY [dbo].[PatternStaging].[PatternStagingID] ORDER BY [ExceptionDetail].[ExceptionDetailID] DESC
                             ) AS validrows,
                                             (
                                              SELECT DISTINCT
                                                     valuetitle
                                              FROM [dbo].[Configuration] INNER JOIN [dbo].[ExceptionDetail] ON [dbo].[ExceptionDetail].[MediaStream]
                                              = [dbo].[Configuration].[Value]
                                                                                                               AND
                                                                                                               [dbo].[Configuration].[SystemName] =
                                                                                                               'All'
                                                                                                               AND
                                                                                                               ComponentName = 'Media Stream'
                                                                                                               AND
                                                                                                               value = 'OD'
                                             ) AS MediaStream, [dbo].[ExceptionDetail].[MediaStream] AS [MediaStreamId], [dbo].[PatternStaging].
                                             [CreativeSignature] AS CreativeSignature, '' AS adid, '' AS OccurrenceId, [dbo].[Configuration].
                                             [ValueTitle] AS ExceptionType, [dbo].[ExceptionDetail].[ExceptionStatus] AS ExceptionStatus, [user].
                                             FName+' '+[user].LName AS RaisedBy, CAST([ExceptionDetail].[ExcRaisedOn] AS DATE
                                                                                     ) AS RaisedOn, [dbo].GetAssignedUserName
            ([dbo].[ExceptionDetail].[AssignedToID]
            ) AS AssignedTo, CONVERT(NVARCHAR(MAX), DATEDIFF(day, [dbo].[ExceptionDetail].[ExcRaisedOn], GETDATE())
                                    ) AS Age, [dbo].[PatternStaging].[PatternStagingID] AS KeyID, [dbo].[ExceptionDetail].[ExceptionDetailID]
                                    AS ExceptionID, [PatternStaging].[LanguageID], NULL AS AdvertiserID, [Language].description AS LanguageName,
                                    '' AS Advertiser, [USER].UserID, [ExceptionDetail].[AssignedToID] AS assignedtouserid
     FROM [dbo].[ExceptionDetail] LEFT JOIN [dbo].[Configuration] ON [dbo].[Configuration].[Value] = [dbo].[ExceptionDetail].[ExceptionType]
                                                                     AND
                                                                     [dbo].[Configuration].[ComponentName] = 'Exception Type'
                                                                     AND
                                                                     [dbo].[Configuration].Systemname = 'All'
                                  INNER JOIN [PatternStaging] ON [PatternStaging].[PatternStagingID] = [ExceptionDetail].
                                  [PatternMasterStagingID]
                                  INNER JOIN [Language] ON [Language].LanguageID = [PatternStaging].[LanguageID]
                                  INNER JOIN [user] ON [user].[UserID] = [dbo].[ExceptionDetail].[ExcRaisedBy]
                                                       AND
                                                       ([PatternStaging].[Exception] IS NOT NULL)
                                                       AND
                                                       [dbo].[ExceptionDetail].[MediaStream] = 'OD'
     UNION
     SELECT ROW_NUMBER() OVER
                             (PARTITION BY [dbo].[PatternStaging].[PatternStagingID] ORDER BY [ExceptionDetail].[ExceptionDetailID] DESC
                             ) AS validrows,
                                             (
                                              SELECT DISTINCT
                                                     valuetitle
                                              FROM [dbo].[Configuration] INNER JOIN [dbo].[ExceptionDetail] ON [dbo].[ExceptionDetail].[MediaStream]
                                              = [dbo].[Configuration].[Value]
                                                                                                               AND
                                                                                                               [dbo].[Configuration].[SystemName] =
                                                                                                               'All'
                                                                                                               AND
                                                                                                               ComponentName = 'Media Stream'
                                                                                                               AND
                                                                                                               value = 'OND'
                                             ) AS MediaStream, [dbo].[ExceptionDetail].[MediaStream] AS [MediaStreamId], [CreativeStaging].
                                             CreativeSignature, '' AS adid, '' AS OccurrenceId, [dbo].[Configuration].[ValueTitle] AS ExceptionType,
                                             [dbo].[ExceptionDetail].[ExceptionStatus] AS ExceptionStatus, [user].FName+' '+[user].LName AS RaisedBy,
                                             CAST([ExceptionDetail].[ExcRaisedOn] AS DATE
                                                 ) AS RaisedOn, [dbo].GetAssignedUserName
            ([dbo].[ExceptionDetail].[AssignedToID]
            ) AS AssignedTo, CONVERT(NVARCHAR(MAX), DATEDIFF(day, [dbo].[ExceptionDetail].[ExcRaisedOn], GETDATE())
                                    ) AS Age, [dbo].[PatternStaging].[PatternStagingID] AS KeyID, [dbo].[ExceptionDetail].[ExceptionDetailID] AS
                                    ExceptionID, [PatternStaging].[LanguageID], NULL AS AdvertiserID, [Language].description AS LanguageName, '' AS
                                    Advertiser, [USER].UserID, [ExceptionDetail].[AssignedToID] AS assignedtouserid
     FROM [dbo].[ExceptionDetail] LEFT JOIN [dbo].[Configuration] ON [dbo].[Configuration].[Value] = [dbo].[ExceptionDetail].[ExceptionType]
                                                                     AND
                                                                     [dbo].[Configuration].[ComponentName] = 'Exception Type'
                                                                     AND
                                                                     [dbo].[Configuration].Systemname = 'All'
                                  INNER JOIN [PatternStaging] ON [PatternStaging].[PatternStagingID] = [ExceptionDetail].[PatternMasterStagingID]
                                  INNER JOIN [Language] ON [Language].LanguageID = [PatternStaging].[LanguageID]
                                  INNER JOIN [user] ON [user].[UserID] = [dbo].[ExceptionDetail].[ExcRaisedBy]
                                                       AND
                                                       ([PatternStaging].[Exception] IS NOT NULL)
                                                       AND
                                                       [dbo].[ExceptionDetail].[MediaStream] = 'OND'
                                  INNER JOIN [CreativeStaging] ON [CreativeStaging].[CreativeStagingID] = [PatternStaging].[CreativeStgID]
     UNION
     SELECT ROW_NUMBER() OVER
                             (PARTITION BY [dbo].[PatternStaging].[PatternStagingID] ORDER BY [ExceptionDetail].[ExceptionDetailID] DESC
                             ) AS validrows,
                                             (
                                              SELECT DISTINCT
                                                     valuetitle
                                              FROM [dbo].[Configuration] INNER JOIN [dbo].[ExceptionDetail] ON [dbo].[ExceptionDetail].[MediaStream]
                                              = [dbo].[Configuration].[Value]
                                                                                                               AND
                                                                                                               [dbo].[Configuration].[SystemName] =
                                                                                                               'All'
                                                                                                               AND
                                                                                                               ComponentName = 'Media Stream'
                                                                                                               AND
                                                                                                               value = 'ONV'
                                             ) AS MediaStream, [dbo].[ExceptionDetail].[MediaStream] AS [MediaStreamId], [CreativeStaging].
                                             CreativeSignature, '' AS adid, '' AS OccurrenceId, [dbo].[Configuration].[ValueTitle] AS ExceptionType,
                                             [dbo].[ExceptionDetail].[ExceptionStatus] AS ExceptionStatus, [user].FName+' '+[user].LName AS RaisedBy,
                                             CAST([ExceptionDetail].[ExcRaisedOn] AS DATE
                                                 ) AS RaisedOn, [dbo].GetAssignedUserName
            ([dbo].[ExceptionDetail].[AssignedToID]
            ) AS AssignedTo, CONVERT(NVARCHAR(MAX), DATEDIFF(day, [dbo].[ExceptionDetail].[ExcRaisedOn], GETDATE())
                                    ) AS Age, [dbo].[PatternStaging].[PatternStagingID] AS KeyID, [dbo].[ExceptionDetail].[ExceptionDetailID] AS
                                    ExceptionID, [PatternStaging].[LanguageID], NULL AS AdvertiserID, [Language].description AS LanguageName, '' AS
                                    Advertiser, [USER].UserID, [ExceptionDetail].[AssignedToID] AS assignedtouserid
     FROM [dbo].[ExceptionDetail] LEFT JOIN [dbo].[Configuration] ON [dbo].[Configuration].[Value] = [dbo].[ExceptionDetail].[ExceptionType]
                                                                     AND
                                                                     [dbo].[Configuration].[ComponentName] = 'Exception Type'
                                                                     AND
                                                                     [dbo].[Configuration].Systemname = 'All'
                                  INNER JOIN [PatternStaging] ON [PatternStaging].[PatternStagingID] = [ExceptionDetail].[PatternMasterStagingID]
                                  INNER JOIN [Language] ON [Language].LanguageID = [PatternStaging].[LanguageID]
                                  INNER JOIN [user] ON [user].[UserID] = [dbo].[ExceptionDetail].[ExcRaisedBy]
                                                       AND
                                                       ([PatternStaging].[Exception] IS NOT NULL)
                                                       AND
                                                       [dbo].[ExceptionDetail].[MediaStream] = 'ONV'
                                  INNER JOIN [CreativeStaging] ON [CreativeStaging].[CreativeStagingID] = [PatternStaging].[CreativeStgID]
     UNION
     SELECT ROW_NUMBER() OVER
                             (PARTITION BY [dbo].[PatternStaging].[PatternStagingID] ORDER BY [ExceptionDetail].[ExceptionDetailID] DESC
                             ) AS validrows,
                                             (
                                              SELECT DISTINCT
                                                     valuetitle
                                              FROM [dbo].[Configuration] INNER JOIN [dbo].[ExceptionDetail] ON [dbo].[ExceptionDetail].[MediaStream]
                                              = [dbo].[Configuration].[Value]
                                                                                                               AND
                                                                                                               [dbo].[Configuration].[SystemName] =
                                                                                                               'All'
                                                                                                               AND
                                                                                                               ComponentName = 'Media Stream'
                                                                                                               AND
                                                                                                               value = 'MOB'
                                             ) AS MediaStream, [dbo].[ExceptionDetail].[MediaStream] AS [MediaStreamId], [CreativeStaging].
                                             CreativeSignature, '' AS adid, '' AS OccurrenceId, [dbo].[Configuration].[ValueTitle] AS ExceptionType,
                                             [dbo].[ExceptionDetail].[ExceptionStatus] AS ExceptionStatus, [user].FName+' '+[user].LName AS RaisedBy,
                                             CAST([ExceptionDetail].[ExcRaisedOn] AS DATE
                                                 ) AS RaisedOn, [dbo].GetAssignedUserName
            ([dbo].[ExceptionDetail].[AssignedToID]
            ) AS AssignedTo, CONVERT(NVARCHAR(MAX), DATEDIFF(day, [dbo].[ExceptionDetail].[ExcRaisedOn], GETDATE())
                                    ) AS Age, [dbo].[PatternStaging].[PatternStagingID] AS KeyID, [dbo].[ExceptionDetail].[ExceptionDetailID] AS
                                    ExceptionID, [PatternStaging].[LanguageID], NULL AS AdvertiserID, [Language].description AS LanguageName, '' AS
                                    Advertiser, [USER].UserID, [ExceptionDetail].[AssignedToID] AS assignedtouserid
     FROM [dbo].[ExceptionDetail] LEFT JOIN [dbo].[Configuration] ON [dbo].[Configuration].[Value] = [dbo].[ExceptionDetail].[ExceptionType]
                                                                     AND
                                                                     [dbo].[Configuration].[ComponentName] = 'Exception Type'
                                                                     AND
                                                                     [dbo].[Configuration].Systemname = 'All'
                                  INNER JOIN [PatternStaging] ON [PatternStaging].[PatternStagingID] = [ExceptionDetail].[PatternMasterStagingID]
                                  INNER JOIN [Language] ON [Language].LanguageID = [PatternStaging].[LanguageID]
                                  INNER JOIN [user] ON [user].[UserID] = [dbo].[ExceptionDetail].[ExcRaisedBy]
                                                       AND
                                                       ([PatternStaging].[Exception] IS NOT NULL)
                                                       AND
                                                       [dbo].[ExceptionDetail].[MediaStream] = 'MOB'
                                  INNER JOIN [CreativeStaging] ON [CreativeStaging].[CreativeStagingID] = [PatternStaging].[CreativeStgID]
     UNION

	 SELECT   ROW_NUMBER() OVER (PARTITION BY [dbo].[PatternStaging].[PatternStagingID]
ORDER BY [ExceptionDetail].[ExceptionDetailID] DESC) AS validrows,
    (SELECT DISTINCT valuetitle
      FROM            [dbo].[Configuration] INNER JOIN
                                [dbo].[ExceptionDetail] ON [dbo].[ExceptionDetail].[MediaStream] = [dbo].[Configuration].[Value] AND [dbo].[Configuration].[SystemName] = 'All' AND ComponentName = 'Media Stream' AND value = 'EM') 
AS MediaStream, [dbo].[ExceptionDetail].[MediaStream] AS [MediaStreamId], [CreativeStaging].CreativeSignature, '' AS adid, OccurrenceId, [dbo].[Configuration].[ValueTitle] AS ExceptionType, 
[dbo].[ExceptionDetail].[ExceptionStatus] AS ExceptionStatus, [user].FName + ' ' + [user].LName AS RaisedBy, CAST([ExceptionDetail].[ExcRaisedOn] AS DATE) AS RaisedOn, 
[dbo].GetAssignedUserName([dbo].[ExceptionDetail].[AssignedToID]) AS AssignedTo, CONVERT(NVARCHAR(MAX), DATEDIFF(day, [dbo].[ExceptionDetail].[ExcRaisedOn], GETDATE())) AS Age, 
[dbo].[PatternStaging].[PatternStagingID] AS KeyID, [dbo].[ExceptionDetail].[ExceptionDetailID] AS ExceptionID, [PatternStaging].[LanguageID], NULL AS AdvertiserID, [Language].description AS LanguageName, 
'' AS Advertiser, [USER].UserID, [ExceptionDetail].[AssignedToID] AS assignedtouserid
FROM            [dbo].[ExceptionDetail] LEFT JOIN
                         [dbo].[Configuration] ON [dbo].[Configuration].[Value] = [dbo].[ExceptionDetail].[ExceptionType] AND [dbo].[Configuration].[ComponentName] = 'Exception Type' AND 
                         [dbo].[Configuration].Systemname = 'All' INNER JOIN
                         [PatternStaging] ON [PatternStaging].[PatternStagingID] = [ExceptionDetail].[PatternMasterStagingID] INNER JOIN
                         [Language] ON [Language].LanguageID = [PatternStaging].[LanguageID] INNER JOIN
                         [user] ON [user].[UserID] = [dbo].[ExceptionDetail].[ExcRaisedBy] AND ([PatternStaging].[Exception] IS NOT NULL) AND [dbo].[ExceptionDetail].[MediaStream] = 'EM' INNER JOIN
                         [CreativeStaging] ON [CreativeStaging].[CreativeStagingID] = [PatternStaging].[CreativeStgID]
	UNION

     ----------------------------------------------------------Indexed Records--------------------------------------------------------------------------------------------------



     SELECT 1 AS validrows,
                            (
                             SELECT DISTINCT
                                    ValueTitle
                             FROM [dbo].[Configuration] INNER JOIN [dbo].[Pattern] ON [dbo].[Pattern].[MediaStream] = [dbo].[Configuration].
                             [ConfigurationId]
                                                                                      AND
                                                                                      [dbo].[Configuration].[SystemName] = 'All'
                                                                                      AND
                                                                                      ComponentName = 'Media Stream'
                                                                                      AND
                                                                                      value = 'CIN'
                            ) AS MediaStream,
                                              (
                                               SELECT DISTINCT
                                                      value
                                               FROM [dbo].[Configuration] INNER JOIN [dbo].[Pattern] ON [dbo].[Pattern].[MediaStream] = [dbo].
                                               [Configuration].[ConfigurationId]
                                                                                                        AND
                                                                                                        [dbo].[Configuration].[SystemName] = 'All'
                                                                                                        AND
                                                                                                        ComponentName = 'Media Stream'
                                                                                                        AND
                                                                                                        value = 'CIN'
                                              ) AS MediaStreamId, '' AS CreativeSignature, CAST(Ad.[AdID] AS VARCHAR
                                                                                               ) AS adid, Ad.[PrimaryOccurrenceID] AS OccurrenceId,
                                                                                               [dbo].[Configuration].[ValueTitle] AS ExceptionType,
                                                                                               [dbo].[Configuration].Valuetitle AS ExceptionStatus,
                                                                                               [user].FName+' '+[user].LName AS RaisedBy, CAST(ad.
                                                                                               CreateDate AS DATE
                                                                                                                                              ) AS
                                                                                                                                              RaisedOn,
                                                                                                                                              NULL
                                                                                                                                              AS
                                                                                                                                              AssignedTo,
                                                                                                                                              CONVERT
                                                                                                                                              (
                                                                                                                                              NVARCHAR
                                                                                                                                              (MAX),
                                                                                                                                              (
                                                                                                                                              DATEDIFF
                                                                                                                                              (day,
                                                                                                                                              [dbo]
                                                                                                                                              .ad.
                                                                                                                                              CreateDate,
                                                                                                                                              GETDATE
                                                                                                                                              ()))
                                                                                                                                              ) AS
                                                                                                                                              Age,
                                                                                                                                              CAST(
                                                                                                                                              Ad.
                                                                                                                                              [AdID]
                                                                                                                                              AS
                                                                                                                                              VARCHAR
                                                                                                                                                  )
                                                                                                                                                  AS
                                                                                                                                                  KeyID,
                                                                                                                                                  NULL
                                                                                                                                                  AS
                                                                                                                                                  exceptionid,
                                                                                                                                                  ad
                                                                                                                                                  .
                                                                                                                                                  [LanguageID],
                                                                                                                                                  ad
                                                                                                                                                  .
                                                                                                                                                  [AdvertiserID]
                                                                                                                                                  AS
                                                                                                                                                  Advertiserid,
                                                                                                                                                  [Language]
                                                                                                                                                  .
                                                                                                                                                  description
                                                                                                                                                  AS
                                                                                                                                                  LanguageName,
                                                                                                                                                  [Advertiser]
                                                                                                                                                  .
                                                                                                                                                  Descrip
                                                                                                                                                  AS
                                                                                                                                                  Advertiser,
                                                                                                                                                  [USER]
                                                                                                                                                  .
                                                                                                                                                  UserID,
                                                                                                                                                  NULL
                                                                                                                                                  AS
                                                                                                                                                  assignedtouserid
     FROM Ad INNER JOIN [dbo].[OccurrenceDetailCIN] ON Ad.[PrimaryOccurrenceID] = [dbo].[OccurrenceDetailCIN].[OccurrenceDetailCINID]
             INNER JOIN [dbo].[Pattern] ON [dbo].[Pattern].[PatternID] = [dbo].[OccurrenceDetailCIN].[PatternID]
             INNER JOIN [dbo].[Creative] ON [dbo].[Creative].PK_Id = [dbo].[Pattern].[CreativeID]
             INNER JOIN [dbo].[Configuration] ON [dbo].[Configuration].[ConfigurationId] = [dbo].[Creative].PrimaryQuality
             INNER JOIN [Language] ON [Language].LanguageID = ad.[LanguageID]
             INNER JOIN [user] ON [user].UserId = Ad.CreatedBy
             INNER JOIN [Advertiser] ON [Advertiser].AdvertiserID = ad.[AdvertiserID]
                                        AND
                                        dbo.fn_IsCreativeBad
          ([dbo].[Configuration].[ConfigurationId]
          ) = 1
     UNION
     SELECT 1 AS validrows,
                            (
                             SELECT DISTINCT
                                    ValueTitle
                             FROM [dbo].[Configuration] INNER JOIN [dbo].[Pattern] ON [dbo].[Pattern].[MediaStream] = [dbo].[Configuration].
                             [ConfigurationId]
                                                                                      AND
                                                                                      [dbo].[Configuration].[SystemName] = 'All'
                                                                                      AND
                                                                                      ComponentName = 'Media Stream'
                                                                                      AND
                                                                                      value = 'TV'
                            ) AS MediaStream,
                                              (
                                               SELECT DISTINCT
                                                      value
                                               FROM [dbo].[Configuration] INNER JOIN [dbo].[Pattern] ON [dbo].[Pattern].[MediaStream] = [dbo].
                                               [Configuration].[ConfigurationId]
                                                                                                        AND
                                                                                                        [dbo].[Configuration].[SystemName] = 'All'
                                                                                                        AND
                                                                                                        ComponentName = 'Media Stream'
                                                                                                        AND
                                                                                                        value = 'TV'
                                              ) AS MediaStreamId, '' AS CreativeSignature, CAST(Ad.[AdID] AS VARCHAR
                                                                                               ) AS adid, Ad.[PrimaryOccurrenceID] AS OccurrenceId,
                                                                                               [dbo].[Configuration].[ValueTitle] AS ExceptionType,
                                                                                               [dbo].[Configuration].Valuetitle AS ExceptionStatus,
                                                                                               [user].FName+' '+[user].LName AS RaisedBy, CAST(ad.
                                                                                               CreateDate AS DATE
                                                                                                                                              ) AS
                                                                                                                                              RaisedOn,
                                                                                                                                              NULL
                                                                                                                                              AS
                                                                                                                                              AssignedTo,
                                                                                                                                              CONVERT
                                                                                                                                              (
                                                                                                                                              NVARCHAR
                                                                                                                                              (MAX),
                                                                                                                                              (
                                                                                                                                              DATEDIFF
                                                                                                                                              (day,
                                                                                                                                              [dbo]
                                                                                                                                              .ad.
                                                                                                                                              CreateDate,
                                                                                                                                              GETDATE
                                                                                                                                              ()))
                                                                                                                                              ) AS
                                                                                                                                              Age,
                                                                                                                                              CAST(
                                                                                                                                              Ad.
                                                                                                                                              [AdID]
                                                                                                                                              AS
                                                                                                                                              VARCHAR
                                                                                                                                                  )
                                                                                                                                                  AS
                                                                                                                                                  KeyID,
                                                                                                                                                  NULL
                                                                                                                                                  AS
                                                                                                                                                  exceptionid,
                                                                                                                                                  ad
                                                                                                                                                  .
                                                                                                                                                  [LanguageID],
                                                                                                                                                  ad
                                                                                                                                                  .
                                                                                                                                                  [AdvertiserID]
                                                                                                                                                  AS
                                                                                                                                                  AdvertiserID,
                                                                                                                                                  [Language]
                                                                                                                                                  .
                                                                                                                                                  description
                                                                                                                                                  AS
                                                                                                                                                  LanguageName,
                                                                                                                                                  [Advertiser]
                                                                                                                                                  .
                                                                                                                                                  Descrip
                                                                                                                                                  AS
                                                                                                                                                  Advertiser,
                                                                                                                                                  [USER]
                                                                                                                                                  .
                                                                                                                                                  UserID,
                                                                                                                                                  NULL
                                                                                                                                                  AS
                                                                                                                                                  assignedtouserid
     FROM Ad INNER JOIN [dbo].[OccurrenceDetailTV] ON Ad.[PrimaryOccurrenceID] = [dbo].[OccurrenceDetailTV].[OccurrenceDetailTVID]
             INNER JOIN [dbo].[Pattern] ON [dbo].[Pattern].[PatternID] = [dbo].[OccurrenceDetailTV].[PatternID]
             INNER JOIN [dbo].[Creative] ON [dbo].[Creative].PK_Id = [dbo].[Pattern].[CreativeID]
             INNER JOIN [dbo].[Configuration] ON [dbo].[Configuration].[ConfigurationId] = [dbo].[Creative].[PrimaryQuality]
             INNER JOIN [Language] ON [Language].LanguageID = ad.[LanguageID]
             INNER JOIN [user] ON [user].UserId = Ad.CreatedBy
             INNER JOIN [Advertiser] ON [Advertiser].AdvertiserID = ad.[AdvertiserID]
                                        AND
                                        dbo.fn_IsCreativeBad
          ([dbo].[Configuration].[ConfigurationId]
          ) = 1
     UNION
     SELECT 1 AS validrows,
                            (
                             SELECT DISTINCT
                                    ValueTitle
                             FROM [dbo].[Configuration] INNER JOIN [dbo].[Pattern] ON [dbo].[Pattern].[MediaStream] = [dbo].[Configuration].
                             [ConfigurationId]
                                                                                      AND
                                                                                      [dbo].[Configuration].[SystemName] = 'All'
                                                                                      AND
                                                                                      ComponentName = 'Media Stream'
                                                                                      AND
                                                                                      value = 'RAD'
                            ) AS MediaStream,
                                              (
                                               SELECT DISTINCT
                                                      value
                                               FROM [dbo].[Configuration] INNER JOIN [dbo].[Pattern] ON [dbo].[Pattern].[MediaStream] = [dbo].
                                               [Configuration].[ConfigurationId]
                                                                                                        AND
                                                                                                        [dbo].[Configuration].[SystemName] = 'All'
                                                                                                        AND
                                                                                                        ComponentName = 'Media Stream'
                                                                                                        AND
                                                                                                        value = 'RAD'
                                              ) AS MediaStreamId, '' AS CreativeSignature, CAST(Ad.[AdID] AS VARCHAR
                                                                                               ) AS adid, Ad.[PrimaryOccurrenceID] AS OccurrenceId,
                                                                                               [dbo].[Configuration].[ValueTitle] AS ExceptionType,
                                                                                               [dbo].[Configuration].Valuetitle AS ExceptionStatus,
                                                                                               [user].FName+' '+[user].LName AS RaisedBy, CAST(ad.
                                                                                               CreateDate AS DATE
                                                                                                                                              ) AS
                                                                                                                                              RaisedOn,
                                                                                                                                              NULL
                                                                                                                                              AS
                                                                                                                                              AssignedTo,
                                                                                                                                              CONVERT
                                                                                                                                              (
                                                                                                                                              NVARCHAR
                                                                                                                                              (MAX),
                                                                                                                                              (
                                                                                                                                              DATEDIFF
                                                                                                                                              (day,
                                                                                                                                              [dbo]
                                                                                                                                              .ad.
                                                                                                                                              CreateDate,
                                                                                                                                              GETDATE
                                                                                                                                              ()))
                                                                                                                                              ) AS
                                                                                                                                              Age,
                                                                                                                                              CAST(
                                                                                                                                              Ad.
                                                                                                                                              [AdID]
                                                                                                                                              AS
                                                                                                                                              VARCHAR
                                                                                                                                                  )
                                                                                                                                                  AS
                                                                                                                                                  KeyID,
                                                                                                                                                  NULL
                                                                                                                                                  AS
                                                                                                                                                  exceptionid,
                                                                                                                                                  ad
                                                                                                                                                  .
                                                                                                                                                  [LanguageID],
                                                                                                                                                  ad
                                                                                                                                                  .
                                                                                                                                                  [AdvertiserID]
                                                                                                                                                  AS
                                                                                                                                                  AdvertiserID,
                                                                                                                                                  [Language]
                                                                                                                                                  .
                                                                                                                                                  description
                                                                                                                                                  AS
                                                                                                                                                  LanguageName,
                                                                                                                                                  [Advertiser]
                                                                                                                                                  .
                                                                                                                                                  Descrip
                                                                                                                                                  AS
                                                                                                                                                  Advertiser,
                                                                                                                                                  [USER]
                                                                                                                                                  .
                                                                                                                                                  UserID,
                                                                                                                                                  NULL
                                                                                                                                                  AS
                                                                                                                                                  assignedtouserid
     FROM Ad INNER JOIN [dbo].[OccurrenceDetailRA] ON Ad.[PrimaryOccurrenceID] = [dbo].[OccurrenceDetailRA].[OccurrenceDetailRAID]
             INNER JOIN [dbo].[Pattern] ON [dbo].[Pattern].[PatternID] = [dbo].[OccurrenceDetailRA].[PatternID]
             INNER JOIN [dbo].[Creative] ON [dbo].[Creative].PK_Id = [dbo].[Pattern].[CreativeID]
             INNER JOIN [dbo].[Configuration] ON [dbo].[Configuration].[ConfigurationId] = [dbo].[Creative].[PrimaryQuality]
             INNER JOIN [Language] ON [Language].LanguageID = ad.[LanguageID]
             INNER JOIN [user] ON [user].UserId = Ad.CreatedBy
             INNER JOIN [Advertiser] ON [Advertiser].AdvertiserID = ad.[AdvertiserID]
             INNER JOIN RCSACIDTORCSCREATIVEIDMAP ON [OccurrenceDetailRA].[RCSAcIdID] = RCSACIDTORCSCREATIVEIDMAP.[RCSAcIdToRCSCreativeIdMapID]
             INNER JOIN [RCSCreative] ON RCSACIDTORCSCREATIVEIDMAP.[RCSCreativeID] = [RCSCreative].[RCSCreativeID]
                                         AND
                                         dbo.fn_IsCreativeBad
          ([dbo].[Configuration].[ConfigurationId]
          ) = 1
     UNION
     SELECT 1 AS validrows,
                            (
                             SELECT DISTINCT
                                    ValueTitle
                             FROM [dbo].[Configuration] INNER JOIN [dbo].[Pattern] ON [dbo].[Pattern].[MediaStream] = [dbo].[Configuration].
                             [ConfigurationId]
                                                                                      AND
                                                                                      [dbo].[Configuration].[SystemName] = 'All'
                                                                                      AND
                                                                                      ComponentName = 'Media Stream'
                                                                                      AND
                                                                                      value = 'OD'
                            ) AS MediaStream,
                                              (
                                               SELECT DISTINCT
                                                      value
                                               FROM [dbo].[Configuration] INNER JOIN [dbo].[Pattern] ON [dbo].[Pattern].[MediaStream] = [dbo].
                                               [Configuration].[ConfigurationId]
                                                                                                        AND
                                                                                                        [dbo].[Configuration].[SystemName] = 'All'
                                                                                                        AND
                                                                                                        ComponentName = 'Media Stream'
                                                                                                        AND
                                                                                                        value = 'OD'
                                              ) AS MediaStreamId, '' AS CreativeSignature, CAST(Ad.[AdID] AS VARCHAR
                                                                                               ) AS adid, Ad.[PrimaryOccurrenceID] AS OccurrenceId,
                                                                                               [dbo].[Configuration].[ValueTitle] AS ExceptionType,
                                                                                               [dbo].[Configuration].Valuetitle AS ExceptionStatus,
                                                                                               [user].FName+' '+[user].LName AS RaisedBy, CAST(ad.
                                                                                               CreateDate AS DATE
                                                                                                                                              ) AS
                                                                                                                                              RaisedOn,
                                                                                                                                              NULL
                                                                                                                                              AS
                                                                                                                                              AssignedTo,
                                                                                                                                              CONVERT
                                                                                                                                              (
                                                                                                                                              NVARCHAR
                                                                                                                                              (MAX),
                                                                                                                                              (
                                                                                                                                              DATEDIFF
                                                                                                                                              (day,
                                                                                                                                              [dbo]
                                                                                                                                              .ad.
                                                                                                                                              CreateDate,
                                                                                                                                              GETDATE
                                                                                                                                              ()))
                                                                                                                                              ) AS
                                                                                                                                              Age,
                                                                                                                                              CAST(
                                                                                                                                              Ad.
                                                                                                                                              [AdID]
                                                                                                                                              AS
                                                                                                                                              VARCHAR
                                                                                                                                                  )
                                                                                                                                                  AS
                                                                                                                                                  KeyID,
                                                                                                                                                  NULL
                                                                                                                                                  AS
                                                                                                                                                  exceptionid,
                                                                                                                                                  ad
                                                                                                                                                  .
                                                                                                                                                  [LanguageID],
                                                                                                                                                  ad
                                                                                                                                                  .
                                                                                                                                                  [AdvertiserID]
                                                                                                                                                  AS
                                                                                                                                                  AdvertiserID,
                                                                                                                                                  [Language]
                                                                                                                                                  .
                                                                                                                                                  description
                                                                                                                                                  AS
                                                                                                                                                  LanguageName,
                                                                                                                                                  [Advertiser]
                                                                                                                                                  .
                                                                                                                                                  Descrip
                                                                                                                                                  AS
                                                                                                                                                  Advertiser,
                                                                                                                                                  [USER]
                                                                                                                                                  .
                                                                                                                                                  UserID,
                                                                                                                                                  NULL
                                                                                                                                                  AS
                                                                                                                                                  assignedtouserid
     FROM Ad INNER JOIN [dbo].[OccurrenceDetailODR] ON Ad.[PrimaryOccurrenceID] = [dbo].[OccurrenceDetailODR].[OccurrenceDetailODRID]
             INNER JOIN [dbo].[Pattern] ON [dbo].[Pattern].[PatternID] = [dbo].[OccurrenceDetailODR].[PatternID]
             INNER JOIN [dbo].[Creative] ON [dbo].[Creative].pk_id = [dbo].[Pattern].[CreativeID]
             INNER JOIN [Advertiser] ON [Advertiser].AdvertiserID = ad.[AdvertiserID]
             INNER JOIN [dbo].[Configuration] ON [dbo].[Configuration].[ConfigurationId] = [dbo].[Creative].[PrimaryQuality]
             INNER JOIN [Language] ON [Language].LanguageID = ad.[LanguageID]
             INNER JOIN [user] ON [user].UserId = Ad.CreatedBy
                                  AND
                                  dbo.fn_IsCreativeBad
          ([dbo].[Configuration].[ConfigurationId]
          ) = 1
     UNION
     SELECT 1 AS validrows,
                            (
                             SELECT DISTINCT
                                    ValueTitle
                             FROM [dbo].[Configuration] INNER JOIN [dbo].[Pattern] ON [dbo].[Pattern].[MediaStream] = [dbo].[Configuration].
                             [ConfigurationId]
                                                                                      AND
                                                                                      [dbo].[Configuration].[SystemName] = 'All'
                                                                                      AND
                                                                                      ComponentName = 'Media Stream'
                                                                                      AND
                                                                                      value = 'OND'
                            ) AS MediaStream,
                                              (
                                               SELECT DISTINCT
                                                      value
                                               FROM [dbo].[Configuration] INNER JOIN [dbo].[Pattern] ON [dbo].[Pattern].[MediaStream] = [dbo].
                                               [Configuration].[ConfigurationId]
                                                                                                        AND
                                                                                                        [dbo].[Configuration].[SystemName] = 'All'
                                                                                                        AND
                                                                                                        ComponentName = 'Media Stream'
                                                                                                        AND
                                                                                                        value = 'OND'
                                              ) AS MediaStreamId, '' AS CreativeSignature, CAST(Ad.[AdID] AS VARCHAR
                                                                                               ) AS adid, Ad.[PrimaryOccurrenceID] AS OccurrenceId,
                                                                                               [dbo].[Configuration].[ValueTitle] AS ExceptionType,
                                                                                               [dbo].[Configuration].Valuetitle AS ExceptionStatus,
                                                                                               [user].FName+' '+[user].LName AS RaisedBy, CAST(ad.
                                                                                               CreateDate AS DATE
                                                                                                                                              ) AS
                                                                                                                                              RaisedOn,
                                                                                                                                              NULL
                                                                                                                                              AS
                                                                                                                                              AssignedTo,
                                                                                                                                              CONVERT
                                                                                                                                              (
                                                                                                                                              NVARCHAR
                                                                                                                                              (MAX),
                                                                                                                                              (
                                                                                                                                              DATEDIFF
                                                                                                                                              (day,
                                                                                                                                              [dbo]
                                                                                                                                              .ad.
                                                                                                                                              CreateDate,
                                                                                                                                              GETDATE
                                                                                                                                              ()))
                                                                                                                                              ) AS
                                                                                                                                              Age,
                                                                                                                                              CAST(
                                                                                                                                              Ad.
                                                                                                                                              [AdID]
                                                                                                                                              AS
                                                                                                                                              VARCHAR
                                                                                                                                                  )
                                                                                                                                                  AS
                                                                                                                                                  KeyID,
                                                                                                                                                  NULL
                                                                                                                                                  AS
                                                                                                                                                  exceptionid,
                                                                                                                                                  ad
                                                                                                                                                  .
                                                                                                                                                  [LanguageID],
                                                                                                                                                  ad
                                                                                                                                                  .
                                                                                                                                                  [AdvertiserID]
                                                                                                                                                  AS
                                                                                                                                                  AdvertiserID,
                                                                                                                                                  [Language]
                                                                                                                                                  .
                                                                                                                                                  description
                                                                                                                                                  AS
                                                                                                                                                  LanguageName,
                                                                                                                                                  [Advertiser]
                                                                                                                                                  .
                                                                                                                                                  Descrip
                                                                                                                                                  AS
                                                                                                                                                  Advertiser,
                                                                                                                                                  [USER]
                                                                                                                                                  .
                                                                                                                                                  UserID,
                                                                                                                                                  NULL
                                                                                                                                                  AS
                                                                                                                                                  assignedtouserid
     FROM Ad INNER JOIN [dbo].[OccurrenceDetailOND] ON Ad.[PrimaryOccurrenceID] = [dbo].[OccurrenceDetailOND].[OccurrenceDetailONDID]
             INNER JOIN [dbo].[Pattern] ON [dbo].[Pattern].[PatternID] = [dbo].[OccurrenceDetailOND].[PatternID]
             INNER JOIN [dbo].[Creative] ON [dbo].[Creative].pk_id = [dbo].[Pattern].[CreativeID]
             INNER JOIN [Advertiser] ON [Advertiser].AdvertiserID = ad.[AdvertiserID]
             INNER JOIN [dbo].[Configuration] ON [dbo].[Configuration].[ConfigurationId] = [dbo].[Creative].[PrimaryQuality]
             INNER JOIN [Language] ON [Language].LanguageID = ad.[LanguageID]
             INNER JOIN [user] ON [user].UserId = Ad.CreatedBy
                                  AND
                                  dbo.fn_IsCreativeBad
          ([dbo].[Configuration].[ConfigurationId]
          ) = 1
     UNION
     SELECT 1 AS validrows,
                            (
                             SELECT DISTINCT
                                    ValueTitle
                             FROM [dbo].[Configuration] INNER JOIN [dbo].[Pattern] ON [dbo].[Pattern].[MediaStream] = [dbo].[Configuration].
                             [ConfigurationId]
                                                                                      AND
                                                                                      [dbo].[Configuration].[SystemName] = 'All'
                                                                                      AND
                                                                                      ComponentName = 'Media Stream'
                                                                                      AND
                                                                                      value = 'ONV'
                            ) AS MediaStream,
                                              (
                                               SELECT DISTINCT
                                                      value
                                               FROM [dbo].[Configuration] INNER JOIN [dbo].[Pattern] ON [dbo].[Pattern].[MediaStream] = [dbo].
                                               [Configuration].[ConfigurationId]
                                                                                                        AND
                                                                                                        [dbo].[Configuration].[SystemName] = 'All'
                                                                                                        AND
                                                                                                        ComponentName = 'Media Stream'
                                                                                                        AND
                                                                                                        value = 'ONV'
                                              ) AS MediaStreamId, '' AS CreativeSignature, CAST(Ad.[AdID] AS VARCHAR
                                                                                               ) AS adid, Ad.[PrimaryOccurrenceID] AS OccurrenceId,
                                                                                               [dbo].[Configuration].[ValueTitle] AS ExceptionType,
                                                                                               [dbo].[Configuration].Valuetitle AS ExceptionStatus,
                                                                                               [user].FName+' '+[user].LName AS RaisedBy, CAST(ad.
                                                                                               CreateDate AS DATE
                                                                                                                                              ) AS
                                                                                                                                              RaisedOn,
                                                                                                                                              NULL
                                                                                                                                              AS
                                                                                                                                              AssignedTo,
                                                                                                                                              CONVERT
                                                                                                                                              (
                                                                                                                                              NVARCHAR
                                                                                                                                              (MAX),
                                                                                                                                              (
                                                                                                                                              DATEDIFF
                                                                                                                                              (day,
                                                                                                                                              [dbo]
                                                                                                                                              .ad.
                                                                                                                                              CreateDate,
                                                                                                                                              GETDATE
                                                                                                                                              ()))
                                                                                                                                              ) AS
                                                                                                                                              Age,
                                                                                                                                              CAST(
                                                                                                                                              Ad.
                                                                                                                                              [AdID]
                                                                                                                                              AS
                                                                                                                                              VARCHAR
                                                                                                                                                  )
                                                                                                                                                  AS
                                                                                                                                                  KeyID,
                                                                                                                                                  NULL
                                                                                                                                                  AS
                                                                                                                                                  exceptionid,
                                                                                                                                                  ad
                                                                                                                                                  .
                                                                                                                                                  [LanguageID],
                                                                                                                                                  ad
                                                                                                                                                  .
                                                                                                                                                  [AdvertiserID]
                                                                                                                                                  AS
                                                                                                                                                  AdvertiserID,
                                                                                                                                                  [Language]
                                                                                                                                                  .
                                                                                                                                                  description
                                                                                                                                                  AS
                                                                                                                                                  LanguageName,
                                                                                                                                                  [Advertiser]
                                                                                                                                                  .
                                                                                                                                                  Descrip
                                                                                                                                                  AS
                                                                                                                                                  Advertiser,
                                                                                                                                                  [USER]
                                                                                                                                                  .
                                                                                                                                                  UserID,
                                                                                                                                                  NULL
                                                                                                                                                  AS
                                                                                                                                                  assignedtouserid
     FROM Ad INNER JOIN [dbo].[OccurrenceDetailONV] ON Ad.[PrimaryOccurrenceID] = [dbo].[OccurrenceDetailONV].[OccurrenceDetailONVID]
             INNER JOIN [dbo].[Pattern] ON [dbo].[Pattern].[PatternID] = [dbo].[OccurrenceDetailONV].[PatternID]
             INNER JOIN [dbo].[Creative] ON [dbo].[Creative].pk_id = [dbo].[Pattern].[CreativeID]
             INNER JOIN [Advertiser] ON [Advertiser].AdvertiserID = ad.[AdvertiserID]
             INNER JOIN [dbo].[Configuration] ON [dbo].[Configuration].[ConfigurationId] = [dbo].[Creative].[PrimaryQuality]
             INNER JOIN [Language] ON [Language].LanguageID = ad.[LanguageID]
             INNER JOIN [user] ON [user].UserId = Ad.CreatedBy
                                  AND
                                  dbo.fn_IsCreativeBad
          ([dbo].[Configuration].[ConfigurationId]
          ) = 1
     UNION
     SELECT 1 AS validrows,
                            (
                             SELECT DISTINCT
                                    ValueTitle
                             FROM [dbo].[Configuration] INNER JOIN [dbo].[Pattern] ON [dbo].[Pattern].[MediaStream] = [dbo].[Configuration].
                             [ConfigurationId]
                                                                                      AND
                                                                                      [dbo].[Configuration].[SystemName] = 'All'
                                                                                      AND
                                                                                      ComponentName = 'Media Stream'
                                                                                      AND
                                                                                      value = 'MOB'
                            ) AS MediaStream,
                                              (
                                               SELECT DISTINCT
                                                      value
                                               FROM [dbo].[Configuration] INNER JOIN [dbo].[Pattern] ON [dbo].[Pattern].[MediaStream] = [dbo].
                                               [Configuration].[ConfigurationId]
                                                                                                        AND
                                                                                                        [dbo].[Configuration].[SystemName] = 'All'
                                                                                                        AND
                                                                                                        ComponentName = 'Media Stream'
                                                                                                        AND
                                                                                                        value = 'MOB'
                                              ) AS MediaStreamId, '' AS CreativeSignature, CAST(Ad.[AdID] AS VARCHAR
                                                                                               ) AS adid, Ad.[PrimaryOccurrenceID] AS OccurrenceId,
                                                                                               [dbo].[Configuration].[ValueTitle] AS ExceptionType,
                                                                                               [dbo].[Configuration].Valuetitle AS ExceptionStatus,
                                                                                               [user].FName+' '+[user].LName AS RaisedBy, CAST(ad.
                                                                                               CreateDate AS DATE
                                                                                                                                              ) AS
                                                                                                                                              RaisedOn,
                                                                                                                                              NULL
                                                                                                                                              AS
                                                                                                                                              AssignedTo,
                                                                                                                                              CONVERT
                                                                                                                                              (
                                                                                                                                              NVARCHAR
                                                                                                                                              (MAX),
                                                                                                                                              (
                                                                                                                                              DATEDIFF
                                                                                                                                              (day,
                                                                                                                                              [dbo]
                                                                                                                                              .ad.
                                                                                                                                              CreateDate,
                                                                                                                                              GETDATE
                                                                                                                                              ()))
                                                                                                                                              ) AS
                                                                                                                                              Age,
                                                                                                                                              CAST(
                                                                                                                                              Ad.
                                                                                                                                              [AdID]
                                                                                                                                              AS
                                                                                                                                              VARCHAR
                                                                                                                                                  )
                                                                                                                                                  AS
                                                                                                                                                  KeyID,
                                                                                                                                                  NULL
                                                                                                                                                  AS
                                                                                                                                                  exceptionid,
                                                                                                                                                  ad
                                                                                                                                                  .
                                                                                                                                                  [LanguageID],
                                                                                                                                                  ad
                                                                                                                                                  .
                                                                                                                                                  [AdvertiserID]
                                                                                                                                                  AS
                                                                                                                                                  AdvertiserID,
                                                                                                                                                  [Language]
                                                                                                                                                  .
                                                                                                                                                  description
                                                                                                                                                  AS
                                                                                                                                                  LanguageName,
                                                                                                                                                  [Advertiser]
                                                                                                                                                  .
                                                                                                                                                  Descrip
                                                                                                                                                  AS
                                                                                                                                                  Advertiser,
                                                                                                                                                  [USER]
                                                                                                                                                  .
                                                                                                                                                  UserID,
                                                                                                                                                  NULL
                                                                                                                                                  AS
                                                                                                                                                  assignedtouserid
     FROM Ad INNER JOIN [dbo].[OccurrenceDetailMOB] ON Ad.[PrimaryOccurrenceID] = [dbo].[OccurrenceDetailMOB].[OccurrenceDetailMOBID]
             INNER JOIN [dbo].[Pattern] ON [dbo].[Pattern].[PatternID] = [dbo].[OccurrenceDetailMOB].[PatternID]
             INNER JOIN [dbo].[Creative] ON [dbo].[Creative].pk_id = [dbo].[Pattern].[CreativeID]
             INNER JOIN [Advertiser] ON [Advertiser].AdvertiserID = ad.[AdvertiserID]
             INNER JOIN [dbo].[Configuration] ON [dbo].[Configuration].[ConfigurationId] = [dbo].[Creative].[PrimaryQuality]
             INNER JOIN [Language] ON [Language].LanguageID = ad.[LanguageID]
             INNER JOIN [user] ON [user].UserId = Ad.CreatedBy
                                  AND
                                  dbo.fn_IsCreativeBad
          ([dbo].[Configuration].[ConfigurationId]
          ) = 1

		  UNION
		  
SELECT        1 AS validrows,
                             (SELECT DISTINCT ValueTitle
                               FROM            [dbo].[Configuration] INNER JOIN
                                                         [dbo].[Pattern] ON [dbo].[Pattern].[MediaStream] = [dbo].[Configuration].[ConfigurationId] AND [dbo].[Configuration].[SystemName] = 'All' AND ComponentName = 'Media Stream' AND value = 'EM') 
                         AS MediaStream,
                             (SELECT DISTINCT value
                               FROM            [dbo].[Configuration] INNER JOIN
                                                         [dbo].[Pattern] ON [dbo].[Pattern].[MediaStream] = [dbo].[Configuration].[ConfigurationId] AND [dbo].[Configuration].[SystemName] = 'All' AND ComponentName = 'Media Stream' AND value = 'EM') 
                         AS MediaStreamId, '' AS CreativeSignature, CAST(Ad.[AdID] AS VARCHAR) AS adid, Ad.[PrimaryOccurrenceID] AS OccurrenceId, [dbo].[Configuration].[ValueTitle] AS ExceptionType, 
                         [dbo].[Configuration].Valuetitle AS ExceptionStatus, [user].FName + ' ' + [user].LName AS RaisedBy, CAST(ad.CreateDate AS DATE) AS RaisedOn, NULL AS AssignedTo, CONVERT(NVARCHAR(MAX), (DATEDIFF(day, 
                         [dbo].ad.CreateDate, GETDATE()))) AS Age, CAST(Ad.[AdID] AS VARCHAR) AS KeyID, NULL AS exceptionid, ad.[LanguageID], ad.[AdvertiserID] AS AdvertiserID, [Language].description AS LanguageName, 
                         [Advertiser].Descrip AS Advertiser, [USER].UserID, NULL AS assignedtouserid
FROM            Ad INNER JOIN
                         [dbo].[OccurrenceDetailEM] ON Ad.[PrimaryOccurrenceID] = [dbo].[OccurrenceDetailEM].[OccurrenceDetailEMID] INNER JOIN
                         [dbo].[Pattern] ON [dbo].[Pattern].[PatternID] = [dbo].[OccurrenceDetailEM].[PatternID] INNER JOIN
                         [dbo].[Creative] ON [dbo].[Creative].pk_id = [dbo].[Pattern].[CreativeID] INNER JOIN
                         [Advertiser] ON [Advertiser].AdvertiserID = ad.[AdvertiserID] INNER JOIN
                         [dbo].[Configuration] ON [dbo].[Configuration].[ConfigurationId] = [dbo].[Creative].[PrimaryQuality] INNER JOIN
                         [Language] ON [Language].LanguageID = ad.[LanguageID] INNER JOIN
                         [user] ON [user].UserId = Ad.CreatedBy AND dbo.fn_IsCreativeBad([dbo].[Configuration].[ConfigurationId]) = 1		  
		  ;