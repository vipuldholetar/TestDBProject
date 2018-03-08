





/*************************************************************************
 stored procedure: mt_proc_TrackFlyerStatus
 created by: Afrecia Stone for Market Track
 modifed by: Jay Hetler
 date: 11/16/2004
 Purpose: Given a project prefix and a FlyerId goes
	checks different tables to see if Entry is complete.
	Marks the status in the WorkStatus table
*************************************************************************/
CREATE PROCEDURE [dbo].[mt_proc_GetCommonColumns]
	@db1 varchar(255), 
	@table1 varchar(255), 
	@db2 varchar(255), 
	@table2 varchar(255), 
	@alias varchar(10),
	@inscols nvarchar(max) OUTPUT,
	@selcols nvarchar(max) OUTPUT
AS

BEGIN

	DECLARE @sql nvarchar(4000)

	set @sql = 'select @selcols = coalesce(@selcols+'','','''')+@alias+''.''+c1.column_name
		, @inscols = coalesce(@inscols+'','','''')+c1.column_name
	from '+@db1+'.information_schema.columns c1
	join '+@db2+'.information_schema.columns c2 on c1.column_name = c2.column_name
	where c1.table_name = @table1
	and c2.table_name = @table2
	order by c1.ordinal_position'

	EXEC sp_executesql @sql, N'@alias varchar(10), @table1 varchar(255), @table2 varchar(255), @inscols nvarchar(max) OUTPUT,@selcols nvarchar(max) OUTPUT', @alias, @table1, @table2, @inscols OUTPUT, @selcols OUTPUT

END



