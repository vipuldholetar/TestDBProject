
CREATE PROCEDURE [dbo].[sp_GetTableData](@TableName as varchar(50))
AS
BEGIN 
DECLARE @Query as varchar(max)
set @Query='SELECT * FROM '+ @TableName
EXECUTE(@Query)
END
