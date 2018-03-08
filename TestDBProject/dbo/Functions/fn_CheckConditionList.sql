CREATE FUNCTION [dbo].[fn_CheckConditionList] (@InStr VARCHAR(MAX), @ConditionID ConditionIdListData READONLY)
RETURNS BIT
AS
BEGIN
	
    ;-- Ensure input ends with comma
	SET @InStr = REPLACE(@InStr + ',', ',,', ',')
	DECLARE @Status BIT
	DECLARE @SP INT
	DECLARE @FinalCount INT
	DECLARE @ParameterTableCount INT
	DECLARE @VALUE VARCHAR(1000)

	DECLARE @TempTab TABLE
	(
	id int not null
	)	
	
	WHILE PATINDEX('%,%', @INSTR ) <> 0 
	BEGIN
	   SELECT  @SP = PATINDEX('%,%',@INSTR)
	   SELECT  @VALUE = LEFT(@INSTR , @SP - 1)
	   SELECT  @INSTR = STUFF(@INSTR, 1, @SP, '')
	   INSERT INTO @TempTab(id) VALUES (@VALUE)
	END
	
/*	
	SELECT @ParameterTableCount= COUNT(*) FROM @ConditionID

	SET @FinalCount= (SELECT COUNT(*) FROM(SELECT * FROM @TempTab UNION SELECT * FROM @ConditionID) AS ID)
	SET @FinalCount= (SELECT COUNT(*) FROM(SELECT * FROM @TempTab union SELECT * FROM @ConditionID) AS ID)
	IF @ParameterTableCount=@FinalCount
*/
    set @FinalCount = (Select count(*) from @TempTab where exists (select 1 from @ConditionID where ConditionID = id))
	if @FinalCount > 0
		BEGIN
			SET @Status = 1
		END
		ELSE
		BEGIN
			SET @Status = 0
		END
	RETURN @Status
END