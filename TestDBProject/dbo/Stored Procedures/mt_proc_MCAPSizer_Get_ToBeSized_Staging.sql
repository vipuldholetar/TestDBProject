



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[mt_proc_MCAPSizer_Get_ToBeSized_Staging]
	-- Add the parameters for the stored procedure here
	@QueueSize int,
	@LocationID int,
	@VehicleID int=0
AS
BEGIN

declare @requestId as varchar(50)
Set @RequestId=newid()
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


select distinct  [CreativeStaging].CreativeStagingID VehicleId, 
	[CreativeStaging].CreatedDt BreakDt,
	[CreativeStaging].CreatedDt CreateDt,
	[CreativeStaging].CreatedDt QCDt,
	 cast(null as datetime) CreateSizedDt, 
	-- CreativeRepository VehicleParentFolder, 
	 CreativeRepository VehicleParentFolder, 
	   0 CheckInPageCount, 
	 count(distinct CreativeDetailStagingEMID) ActualPageCount, 
	 1 Priority, 
	 0 CheckInOccurrences, 
	 22 StatusID, 
	 '' FormName
					  
--select *
					   from [dbo].[CreativeDetailStagingEM]
inner join [CreativeStaging] on [CreativeStaging].CreativeStagingID = [CreativeDetailStagingEM].CreativeStagingID

where [CreativeStaging].createddt > '4/1/2017'
and CreativeRepository like '\EML\%'
and AssetThmbnlName is null
group by [CreativeStaging].CreativeStagingID, 
	[CreativeStaging].CreatedDt, CreativeRepository
union all
select  [CreativeStaging].CreativeStagingID VehicleId, 
	 [CreativeStaging].CreatedDt BreakDt,
	[CreativeStaging].CreatedDt CreateDt,
	[CreativeStaging].CreatedDt QCDt,
	 cast(null as datetime) CreateSizedDt, 
	-- CreativeRepository VehicleParentFolder, 
	 CreativeRepository VehicleParentFolder, 
	   0 CheckInPageCount, 
	 count(distinct CreativeDetailStagingODRID) ActualPageCount, 
	 1 Priority, 
	 0 CheckInOccurrences, 
	 22 StatusID, 
	 '' FormName
					  
--select *
					   from [dbo].[CreativeDetailStagingODR]
inner join [CreativeStaging] on [CreativeStaging].CreativeStagingID = [CreativeDetailStagingODR].CreativeStagingID

where [CreativeDetailStagingODR].CreatedDT > '4/1/2017'
and CreativeRepository like '\OD\%'
and AssetThmbnlName is null
group by [CreativeStaging].CreativeStagingID, 
	[CreativeStaging].CreatedDt, CreativeRepository
order by 4 desc

end



