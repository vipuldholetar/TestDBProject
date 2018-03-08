


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[mt_proc_MCAPSizer_Get_ToBeSized_VehicleID] 
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


select  distinct CreativeMasterId VehicleId, 
	Ad.breakDt BreakDt,
	[CreativeDetailEM].CreatedDt CreateDt,
	[CreativeDetailEM].CreatedDt QCDt,
	 cast(null as datetime) CreateSizedDt, 
	-- CreativeRepository VehicleParentFolder, 
	 CreativeRepository VehicleParentFolder, 
	   0 CheckInPageCount, 
	 count(distinct CreativeDetailsEmID) ActualPageCount, 
	 1 Priority, 
	 0 CheckInOccurrences, 
	 22 StatusID, 
	 '' FormName
					  
--select *
					   from [dbo].[CreativeDetailEM]
inner join [Creative] on [Creative].PK_Id = [CreativeDetailEM].CreativeMasterID
inner join Ad on Ad.AdId = [Creative].AdId 
where [CreativeDetailEM].createddt > '4/1/2017'
and CreativeRepository like '\EML\%'
and AssetThmbnlName is null
group by CreativeMasterId, 
	Ad.breakDt ,
	[CreativeDetailEM].CreatedDt, CreativeRepository
union all
select  distinct CreativeMasterId VehicleId, 
	isnull(Ad.breakDt, [CreativeDetailODR].CreatedDt) BreakDt,
	[CreativeDetailODR].CreatedDt CreateDt,
	[CreativeDetailODR].CreatedDt QCDt,
	 cast(null as datetime) CreateSizedDt, 
	-- CreativeRepository VehicleParentFolder, 
	 CreativeRepository VehicleParentFolder, 
	   0 CheckInPageCount, 
	 count(distinct CreativeDetailODRID) ActualPageCount, 
	 1 Priority, 
	 0 CheckInOccurrences, 
	 22 StatusID, 
	 '' FormName
					  
--select *
					   from [dbo].[CreativeDetailODR]
inner join [Creative] on [Creative].PK_Id = [CreativeDetailODR].CreativeMasterID
inner join Ad on Ad.AdId = [Creative].AdId 
where [CreativeDetailODR].CreatedDT > '4/1/2017'
and CreativeRepository like '\OD\%'
and AssetThmbnlName is null
group by CreativeMasterId, 
	Ad.breakDt ,
	[CreativeDetailODR].CreatedDt, CreativeRepository
order by 4 desc

end


