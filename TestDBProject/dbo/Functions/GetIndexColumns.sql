 
-- Returns the list of columns in the index 
CREATE FUNCTION dbo.GetIndexColumns 
( 
    @table_name SYSNAME, 
    @object_id INT, 
    @index_id TINYINT 
) 
RETURNS NVARCHAR(4000) 
AS 
BEGIN 
    DECLARE 
        @colnames NVARCHAR(4000),  
        @thisColID INT, 
        @thisColName SYSNAME 
         
    SET @colnames = INDEX_COL(@table_name, @index_id, 1) 
        + dbo.GetIndexColumnOrder(@object_id, @index_id, 1) 
 
    SET @thisColID = 2 
    SET @thisColName = INDEX_COL(@table_name, @index_id, @thisColID) 
        + dbo.GetIndexColumnOrder(@object_id, @index_id, @thisColID) 
 
    WHILE (@thisColName IS NOT NULL) 
    BEGIN 
        SET @thisColID = @thisColID + 1 
        SET @colnames = @colnames + ', ' + @thisColName 
 
        SET @thisColName = INDEX_COL(@table_name, @index_id, @thisColID) 
            + dbo.GetIndexColumnOrder(@object_id, @index_id, @thisColID) 
    END 
    RETURN @colNames 
END 
