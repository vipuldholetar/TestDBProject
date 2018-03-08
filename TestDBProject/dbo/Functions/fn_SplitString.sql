CREATE FUNCTION [dbo].[fn_SplitString](            
@String nvarchar(max),            
@Delimiter nvarchar(10)            
)            
Returns @ValueTable table([Value] nvarchar(1000))            
BEGIN            
--To split the input string based on the delimiter            
 DECLARE @NextString nvarchar(4000)            
 DECLARE @Pos int            
 DECLARE @NextPos int            
 DECLARE @COmmaCheck nvarchar(1)            
             
 --Initialise            
 SET @NextString = ''            
 SET @COmmaCheck = right(@String,1)            
             
 --Check for trailing comma,if not exists, Insert            
 SET @String = @String + @Delimiter            
             
 --Get position of  first comma            
 SET @Pos = CHARINDEX(@Delimiter,@String)            
 SET @NextPos = 1            
             
 --Loop while there is still a comma in the string of levels            
 WHILE(@Pos <> 0)            
 BEGIN             
  SET @NextString = SUBSTRING(@String,1,@Pos - 1)            
  INSERT INTO @ValueTable([Value]) VALUES(@NextString)            
  SET @String = SUBSTRING(@String,@Pos + 1,LEN(@String))            
  SET @NextPos = @Pos            
  SET @Pos = CHARINDEX(@Delimiter,@String)            
 END            
RETURN            
END
