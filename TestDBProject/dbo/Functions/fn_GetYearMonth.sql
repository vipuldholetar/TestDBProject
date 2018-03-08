create FUNCTION [dbo].[fn_GetYearMonth](@AdDate DateTime,@Ext BIT)
    RETURNS VARCHAR(max)
AS
begin
  declare @localPath varchar(60)
  declare @Yearmonth varchar(10)
  Declare @Day varchar(10)
  Declare @Path Varchar(50)

  	 set @Yearmonth= CONCAT(datepart (YY, @AdDate), FORMAT ( @AdDate,'MM')) 
	 set @Day =  datepart (DD, cast(@AdDate as dateTime))

	 					  
	set @Path = @Yearmonth

	  if @Ext = 1
	  Begin
		set @Path = @Path + '\' + @Day
	  End 

	  return @Path
end 
