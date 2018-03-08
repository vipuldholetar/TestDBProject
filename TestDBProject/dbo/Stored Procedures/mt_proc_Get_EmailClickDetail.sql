


create   Procedure [dbo].[mt_proc_Get_EmailClickDetail]
	@VehicleID varchar(50),
	@URL varchar(500) output
AS
BEGIN
	select top 1 @URL = MaxOccurURL from  EmailClickDetail where cast(VehicleId as int) = cast(@Vehicleid as int)
	order by ClickEndTime desc

END
