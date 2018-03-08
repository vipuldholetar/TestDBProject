CREATE FUNCTION [dbo].[fn_GetLocalServerPath](
--@AdDate DateTime,
@locationId INT,@SubMainFolder Varchar(12),@mediaType varchar(4),@Ext BIT)
    RETURNS VARCHAR(max)
AS
begin
  declare @localPath varchar(60)
  --declare @Yearmonth varchar(10)
  --Declare @Day varchar(10)
  Declare @Path Varchar(50)

  --	 set @Yearmonth= CONCAT(datepart (YY, @AdDate), FORMAT ( @AdDate,'MM')) 
	 --set @Day =  datepart (DD, cast(@AdDate as dateTime))


  select @localPath = [path] from imagePath 
                      where --yearmonth=@Yearmonth and 
				  locationid=@locationId and mediaTypeid=@mediaType
					  
	set @Path = @localPath --+ @SubMainFolder --+'\'+ @Yearmonth

	 -- if @Ext = 1
	 -- Begin
		--set @Path = @Path + '\' + @Day
	 -- End 

	  return @Path
end 
