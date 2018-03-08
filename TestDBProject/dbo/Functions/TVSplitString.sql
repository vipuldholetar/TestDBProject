-- ==============================================================================================================   
-- Author:    Govardhan   
-- Create date: 07/07/2015   
-- Description:  Get the parse strings 
-- Query :   
/* select dbo.TVSplitString('ATL',',')  
*/ 
-- ================================================================================================================
CREATE FUNCTION [dbo].[TVSplitString]
(    
      @Input NVARCHAR(MAX),
      @Character CHAR(1)
)
RETURNS @Output TABLE (
      SlNo int,
      Item NVARCHAR(1000)
)
AS
BEGIN
      DECLARE @StartIndex INT, @EndIndex INT,@Count int
      
	  SET @Count=1
      SET @StartIndex = 1
      IF SUBSTRING(@Input, LEN(@Input) - 1, LEN(@Input)) <> @Character
      BEGIN
            SET @Input = @Input + @Character
      END
 
      WHILE CHARINDEX(@Character, @Input) > 0
      BEGIN
            SET @EndIndex = CHARINDEX(@Character, @Input)
           
            INSERT INTO @Output(SlNo,Item)
            SELECT @Count,SUBSTRING(@Input, @StartIndex, @EndIndex - 1)
           
            SET @Input = SUBSTRING(@Input, @EndIndex + 1, LEN(@Input))
			SET @Count=@Count+1
      END
 
      RETURN
END
