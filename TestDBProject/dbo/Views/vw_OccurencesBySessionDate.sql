

-- ===============================================================================
-- Author                  : Arun Nair 
-- Create date             : 
-- Execution         : [dbo].[vw_OccurencesBySessionDate]
-- Description             : Load Radio Data
-- Updated By        : Arun Nair on 08/11/2015 - CleanUp for OneMTDB 
--                                  Arun Nair on 11/24/2015 - Added AuditBy,AuditDTM Columns
--=================================================================================
CREATE VIEW [dbo].[vw_OccurencesBySessionDate]
AS
SELECT 'Ingested' AS WorkType,
       [OccurrenceDetailRA].[OccurrenceDetailRAID] AS occurrenceid,
       CONVERT(VARCHAR, [OccurrenceDetailRA].[AirDT], 101) AS LastRunDate, 
       CONVERT(VARCHAR, [OccurrenceDetailRA].[CreatedDT], 101) AS CreateDate,
       [RCSCreative].[RCSCreativeID] As RCSCreativeID,
       'NA'  AS TotalQScore, 
       [Market].[Descrip] AS Market,
       [MarketID] AS MarketID,
       [Language].description AS Language,
       [Language].languageid,
       [RCSAdv].[RCSAdvID] As AdvertiserId,
       [RCSAdv].Name AS Advertiser,
       [CreativeDetailStagingRA].mediaformat AS CreativeFileType,
       [CreativeDetailStagingRA].filesize  AS CreativeFileSize, 
       [CreativeDetailStagingRA].mediafilepath AS CreativeFilepath,
       [RCSAdv].Name   AS RCSParentCompany, 
       [RCSClass].Name AS RCSClass, 
       [RCSAcct].Name AS RCSAccount,
       [RCSAcct].[RCSAcctID]   AS RCSAccountID, 
       [OccurrenceDetailRA].[AirStartDT], 
       [OccurrenceDetailRA].[AirEndDT],
       (Datediff(second, [OccurrenceDetailRA].[AirStartDT],[OccurrenceDetailRA].[AirEndDT])) AS Length,
       [PatternStaging].queryanswer                     AS QandA,
       [PatternStaging].[Exception] As IsException,
       [PatternStaging].[Query]  As IsQuery,
       [PatternStaging].[PatternStagingID] AS PatternMasterStagingID,
       [PatternStaging].[AuditedByID],[PatternStaging].[AuditedDT]
       FROM   [OccurrenceDetailRA] 
       INNER JOIN RCSAcIdToRCSCreativeIdMap  ON [OccurrenceDetailRA].[RCSAcIdID] = RCSAcIdToRCSCreativeIdMap.[RCSAcIdToRCSCreativeIdMapID]
       INNER JOIN [RCSCreative] ON RCSAcIdToRCSCreativeIdMap.[RCSCreativeID] =  [RCSCreative].[RCSCreativeID] 
       INNER JOIN [RCSAdv] ON [RCSCreative].[RCSAdvID] = [RCSAdv].[RCSAdvID] 
       INNER JOIN RadioStation ON RadioStation.[RCSStationID] = [OccurrenceDetailRA].[RCSStationID] and [OccurrenceDetailRA].AirDT between RadioStation.EffectiveDT and RadioStation.EndDT
       INNER JOIN RCSRadioStation ON RadioStation.[RCSStationID] = RCSRadioStation.[RCSRadioStationID]
       INNER JOIN [Market] ON [Market].[MarketID] = RadioStation.dma 
       INNER JOIN [PatternStaging] on [PatternStaging].[PatternID]=[OccurrenceDetailRA].[PatternID]
       INNER JOIN [CreativeStaging] on [CreativeStaging].[CreativeStagingID]=[PatternStaging].[CreativeStgID]
       INNER JOIN [Language] ON [PatternStaging].[LanguageID] = [Language].languageid 
       INNER JOIN [RCSClass] ON [RCSClass].[RCSClassID] = [RCSCreative].[RCSClassID] 
       INNER JOIN [RCSAcct]  ON [RCSAcct].[RCSAcctID] = [RCSCreative].[RCSAcctID] 
       INNER JOIN [CreativeDetailStagingRA] ON [CreativeDetailStagingRA].[CreativeStgID] = [CreativeStaging].[CreativeStagingID] 
       WHERE  [CreativeStaging].Deleted = 0 
       AND [RCSCreative].[Deleted] = 0 
       AND RCSAcIdToRCSCreativeIdMap.[Deleted]=0
       AND [OccurrenceDetailRA].[AdID] IS NULL 
       --AND [OccurrenceDetailRA].[PatternID] IS NULL 
       AND [PatternStaging].[CreativeStgID] IS NOT NULL 
       AND [PatternStaging].[NoTakeReasonCODE] IS NULL 
       AND [PatternStaging].Autoindexing = 0
       AND [PatternStaging].MediaStream = 145