


create   Procedure [dbo].[mt_proc_Insert_EmailClickDetail]
	@VehicleID varchar(50),
	@Description varchar(500),
	@MaxOccurURL varchar(500),
	@MaxOccurCount varchar(50),
	@ClickStartTime DateTime,
	@ClickEndTime DateTime,
	@DateCreated DateTime
AS
BEGIN
	INSERT INTO EmailClickDetail(VehicleID, [Descrip], MaxOccurURL,MaxOccurCount, ClickStartTime,ClickEndTime,[CreateDT])
		Values(@VehicleID, @Description, @MaxOccurURL,@MaxOccurCount, @ClickStartTime,@ClickEndTime,@DateCreated)


END
