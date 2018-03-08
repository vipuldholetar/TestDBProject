CREATE PROCEDURE CreateLogTable 
@TableNameParm varchar(100)
AS
	
declare @TableName varchar(250)
declare @SQL varchar(max)
declare @KeyName varchar(250)
declare @field varchar(250)
declare @maxfield int
declare @fieldname varchar(250)
declare @tempdatatype varchar(250)
declare @datatype varchar(250)
declare @IsNullable varchar(250)
declare @charmaxlength int 
declare @nummaxlength int
declare @decmaxlength int

set @TableName = RTRIM(@TableNameParm) + 'Log'
set @SQL = 'CREATE TABLE ' + @TableName + ' ('
set @SQL = @SQL + 'LogTimeStamp datetime NULL'
set @SQL = @SQL + ',LogDMLOperation char(1) NULL'
set @SQL = @SQL + ',LoginUser varchar(32) NULL'
	
SELECT @KeyName = COLUMN_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS a, INFORMATION_SCHEMA.KEY_COLUMN_USAGE b
WHERE a.TABLE_NAME = @TableNameParm
AND a.CONSTRAINT_TYPE = 'PRIMARY KEY'
AND b.TABLE_NAME = a.TABLE_NAME
AND b.CONSTRAINT_NAME = a.CONSTRAINT_NAME

SELECT @field = 1,
	@maxfield = MAX(ORDINAL_POSITION)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = @TableNameParm

--select * from INFORMATION_SCHEMA.COLUMNS
--select @maxfield
WHILE @field <= @maxfield
BEGIN

     SELECT @fieldname = COLUMN_NAME,
	@datatype = DATA_TYPE,
	@IsNullable = IS_NULLABLE,
	@charmaxlength = CHARACTER_MAXIMUM_LENGTH,	--/ for char and varchar length
	@nummaxlength = NUMERIC_PRECISION,		--/ for int and numeric
	@decmaxlength = NUMERIC_PRECISION_RADIX	--/ for numeric
     FROM INFORMATION_SCHEMA.COLUMNS
     WHERE TABLE_NAME = @TableNameParm
     AND ORDINAL_POSITION = @field

     set @SQL = @SQL + ' ,' + @fieldname + ' '
     set @tempdatatype = @datatype
     IF @charmaxlength IS NOT NULL 
		if @charmaxlength > 0
			set @tempdatatype = @tempdatatype + '(' + STR(@charmaxlength) + ')'
		else
			set @tempdatatype = @tempdatatype + '(MAX)'
     ELSE 
		IF @nummaxlength IS NOT NULL AND UPPER(@datatype) = 'NUMERIC' 
			set @tempdatatype = @tempdatatype + '(' + STR(@nummaxlength) + ',' + STR(@decmaxlength) + ')'
    

     IF @IsNullable = 'Yes' 
		set @tempdatatype = @tempdatatype + ' NULL'
	
		set @SQL = @SQL + @tempdatatype

     IF @fieldname <> @KeyName --THEN	--/ OldVal_ column is applicable only for Non PK
     	set @SQL = @SQL + ', OldVal_' + @fieldname + ' ' + @tempdatatype	
--/ oldval column
    -- ENDIF
	--select @sql
     set @field = @field + 1
	 --select @field
end
set @SQL = @SQL + ');'

set @SQL = @SQL + 'ALTER TABLE ' + @TableName + ' WITH CHECK ADD CHECK ((LogDMLOperation = ''U'' OR LogDMLOperation = ''I'' OR LogDMLOperation = ''D''))'

PRINT @sql 
print LEN(@sql)
--EXEC (@SQL)

RETURN