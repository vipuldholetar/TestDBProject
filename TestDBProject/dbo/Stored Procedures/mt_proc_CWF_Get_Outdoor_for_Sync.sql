



-- =============================================
-- Author:		jhetler
-- Create date: 5/1/2017
-- Description:	Retrieves the latest set of creatives that are need for Omnis Sync
-- =============================================
CREATE PROCEDURE [dbo].[mt_proc_CWF_Get_Outdoor_for_Sync]
--select LastRunDT  from CWF_SyncLog where mediastream='OD'
--Update CWF.dbo.SyncLog set LastRunDT = '5/16/2017' from  CWF.dbo.SyncLog where mediastream='OD'
--select * from tempdb.dbo.OD_Copy
	@CreativeDetailID int = 0
AS
BEGIN
	declare @StartDt datetime
	declare @EndDt datetime

	Set @EndDt = getdate()
	

	select @StartDt =LastRunDT  from CWF.dbo.SyncLog where mediastream='OD'


	--get the latest list if no id is specified
	if @CreativeDetailID = 0
	BEGIN
	/*
		select distinct '\\mt3spend2\UATAssets' + cd.CreativeRepository + cd.CreativeAssetName SourceFile, 
		'\\10.0.100.71\outdoor\CMS_FTP_mirror\Test\' + datename(month, BreakDt)  + ' ' + cast(datepart(YYYY, BreakDt) as varchar)   + '\' + 
		Market.Descrip + '\' as DestinationPath,
		cd.CreativeAssetName  as DestinationFile,
		cast(CD.CreativeDetailODRID as varchar) ID, a.AdID, cast(null as datetime) FileCopyDT--, cd.*
		into tempdb.dbo.OD_Copy
		from Ad a
		join Pattern p on p.AdId = a.AdId and p.MediaStream = 149
		join Creative c on c.AdId = a.AdId
		join CreativeDetailODR cd on cd.CreativeMasterID = c.PK_Id and LegacyCreativeAssetName is null
		join CreativeDetailODRLog l on l.CreativeMasterId = cd.CreativeMasterID 
		inner join Market on Market.MarketId = replace(right(CD.CreativeRepository, 4), '\', '')
		where LogTimeStamp between @StartDt and @EndDt
		order by 1
		*/

		insert into CWF.dbo.OD_CreativeCopy(SourceFile, DestinationPath, DestinationFile, ID, InsertDT, FileCopyDT)
		select distinct '\\mt3spend2\CreativeAssets' + replace(CreativeRepository, '/', '\')  + cd.CreativeAssetName SourceFile, 
		'\\10.0.100.71\outdoor\CMS_FTP_mirror' + replace(SourceFTPFolder, '/', '\') + '\'  as DestinationPath,
		cd.CreativeAssetName  as DestinationFile,
		cast(CD.CreativeDetailStagingODRID as varchar) ID, getdate(), cast(null as datetime) FileCopyDT
		--into tempdb.dbo.OD_Copy
		from 
		CreativeDetailStagingODR cd
		join occurrencedetailODR on ImageFileName = CreativeAssetName
		where CD.CreatedDt between @StartDt and @EndDt
		and CreativeRepository is not null
		order by 1
	END
	ELSE
		--Specific file to copy
	BEGIN
		select distinct '\\mt3spend2\UATAssets' + cd.CreativeRepository + cd.CreativeAssetName SourceFile, 
		LogTimeStamp, LogDMLOperation, a.AdID--, cd.*
		into tempdb.dbo.OD_Copy
		from Ad a
		join Pattern p on p.AdId = a.AdId and p.MediaStream = 149
		join Creative c on c.AdId = a.AdId
		join CreativeDetailODR cd on cd.CreativeMasterID = c.PK_Id and LegacyCreativeAssetName is null
		join CreativeDetailODRLog l on l.CreativeMasterId = cd.CreativeMasterID 
		where CD.CreativeDetailODRID = @CreativeDetailID
	
	END
	select @@Rowcount Row_Count

	Update CWF.dbo.SyncLog set LastRunDT = getdate() from  CWF.dbo.SyncLog where mediastream='OD'
END




