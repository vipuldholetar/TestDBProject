create procedure sp_GetConfiguration (
	@ValueTitle varchar(100),
	@ComponentName varchar(50)
)
as
begin
	select * from [Configuration] 
	where ComponentName = @ComponentName
	and ValueTitle = @ValueTitle
end