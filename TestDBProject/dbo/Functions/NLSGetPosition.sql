-- =============================================   
-- Author:    Govardhan   
-- Create date: 06/01/2015   
-- Description:Get POSITION OF BIT FOR PARTICLUAR OCCURANCE COUNT.  
-- Query :   
/*  

SELECT NIELSONGetPosition '',  
--select (DBO.NLSGetPosition('0000011','1',1,1,2))

*/ 
CREATE FUNCTION [dbo].[NLSGetPosition](@str VARCHAR(8000), @substr VARCHAR(255), @start INT, @occurrence INT, @CountDaysOfWeekIndicator INT)
  RETURNS INT
  AS
  BEGIN
	DECLARE @found INT = @occurrence,
			@pos INT = @start;
 
	WHILE 1=1 
	BEGIN
		-- Find the next occurrence
		SET @pos = CHARINDEX(@substr, @str, @pos);
 
		-- Nothing found
		IF @pos IS NULL OR @pos = 0
			RETURN @pos;
 
		-- The required occurrence found
		IF @found = 1
			BREAK;
 
		-- Prepare to find another one occurrence
		SET @found = @found - 1;
		SET @pos = @pos + 1;

	END
 
 	IF((@CountDaysOfWeekIndicator =1) AND (@pos = 7))
	BEGIN
		SET @pos = case @pos when 7 then 0 else @pos end;
	END	
	
	RETURN @pos;
  END
