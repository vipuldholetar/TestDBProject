
-- Returns whether the column is ASC or DESC 
CREATE FUNCTION dbo.GetIndexColumnOrder 
( 
    @object_id INT, 
    @index_id TINYINT, 
    @column_id TINYINT 
) 
RETURNS NVARCHAR(5) 
AS 
BEGIN 
    DECLARE @r NVARCHAR(5) 
    SELECT @r = CASE INDEXKEY_PROPERTY 
    ( 
        @object_id, 
        @index_id, 
        @column_id, 
        'IsDescending' 
    ) 
        WHEN 1 THEN N' DESC' 
        ELSE N'' 
    END 
    RETURN @r 
END 
