CREATE FUNCTION [dbo].[fn_IsCreativeBad]
(
	@CreativeQualityID int
)
RETURNS int
AS
BEGIN

	DECLARE @Result int

	Declare @values as varchar(100)
	select  @values=value from [Configuration] where [ComponentName]='Creative Quality Bad'

if exists(select configurationid from [Configuration] where value in (select item from splitstring(@values,',')) AND [ComponentName]='Creative Quality' and configurationid =@CreativeQualityID)
begin
set @result=1
end
else
begin
set @result=0
end

	RETURN @Result
END
