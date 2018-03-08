
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[mt_proc_MCAPSizer_Get_ToBeSized]
	-- Add the parameters for the stored procedure here
	@QueueSize int,
	@LocationID int
AS
BEGIN

declare @requestId as varchar(50)
Set @RequestId=newid()
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	
select  CreativeMasterId VehicleId, 
	Ad.breakDt BreakDt,
	[CreativeDetailEM].CreatedDt CreateDt,
	[CreativeDetailEM].CreatedDt QCDt,
	 null CreateSizedDt, 
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
group by CreativeMasterId, 
	Ad.breakDt ,
	[CreativeDetailEM].CreatedDt, CreativeRepository
order by [CreativeDetailEM].createdDt desc

end
