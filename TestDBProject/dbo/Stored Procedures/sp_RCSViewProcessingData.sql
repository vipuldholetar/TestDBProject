-- =============================================        
-- Author:    Govardhan.R        
-- Create date: 04/06/2015        
-- Description:  view the rcs processing data status.        
-- Query : exec sp_RCSViewProcessingData      
-- =============================================        
CREATE procedure [dbo].[sp_RCSViewProcessingData]
as
begin
select 1[SlNo],'RCSXmlDocs'[Table],ISNULL(sum(isnull(xmlnodecount,0)),0)[RecordsCount] from [RCSXmlDocs]
union
select 2[SlNo],'TotalRCSRawData'[Table],count(*)[RecordsCount] from RCSRawData 
union
select 2[SlNo],'IngestedRCSRawData'[Table],count(*)[RecordsCount] from RCSRawData where ingestionstatus=1
union
select 2[SlNo],'PendingRCSRawData'[Table],count(*)[RecordsCount] from RCSRawData where ingestionstatus=0 and action=1
union
select 2[SlNo],'MisMatchRCSRawData'[Table],count(*)[RecordsCount] from RCSRawData where action=0
union
select 3[SlNo],'RCSAdvertisermaster'[Table],count(*)[RecordsCount] from [RCSAdv]
union
select 4[SlNo],'RCSClassMaster'[Table],count(*)[RecordsCount] from [RCSClass]
union
select 5[SlNo],'RCSRadioStation'[Table],count(*)[RecordsCount] from [RCSRadioStation]--
union
select 6[SlNo],'RCSOccurences'[Table],count(*)[RecordsCount]  from [OccurrenceDetailRA]
union
select 7[SlNo],'RCS Creative Signatures'[Table],count(*)[RecordsCount] from [RCSCreative]--
union
select 8[SlNo],'RCSAcidToCreativeMap'[Table],count(*)[RecordsCount] from [RCSAcIdToRCSCreativeIdMap]
union
select 9[SlNo],'RCSReMapLog'[Table],count(*)[RecordsCount] from [RCSIdReMapLog]--
union
select 10[SlNo],'RCSPatterns'[Table],count(*)[RecordsCount] from [PatternStaging] 
union
select 11[SlNo],'RCSPatternDetails'[Table],count(*)[RecordsCount] from [PatternDetailRAStaging]--
union
select 12[SlNo],'RCSPatternsDownloaded'[Table],count(*)[RecordsCount] from [PatternStaging] where [CreativeStgID] is not null
union
select 12[SlNo],'RCSPendingPatternsToDownload'[Table],count(*)[RecordsCount] from [PatternStaging] where [CreativeStgID] is null
union
select 13[SlNo],'RCSCreativedetailsPopulated'[Table],count(*)[RecordsCount] from [CreativeDetailStagingRA]--
union 
select 14[SlNo],'Dates in RCSRawData'[Table],count(a.dates) from
(select distinct convert(date,[StartDT]) as dates from RCSRawData) a
UNION
SELECT 15[SlNo],'Days Of AirDate'[Table], count(DISTINCT CONVERT(DATE,[AirDT])) FROM [OccurrenceDetailRA] WHERE [OccurrenceDetailRAID] IN 
(
SELECT DISTINCT [OccurrenceID] FROM [CreativeStaging] CT 
INNER JOIN [CreativeDetailStagingRA] ST ON ST.[CreativeStgID]=CT.[CreativeStagingID]
)
end