CREATE FUNCTION [dbo].[fn_CINRatingString] 
(
	@Rating  VARCHAR(4)
)
RETURNS VARCHAR(MAX)
AS
BEGIN

	DECLARE @Result VARCHAR(MAX)
	DECLARE @TEST INT
	DECLARE @FinalRsult VARCHAR(MAX)
	DECLARE @Length INT

	IF(@Rating<>'')

	BEGIN
	
	SET @TEST = SUBSTRING(@Rating,1,1)
		IF(@TEST= 1)
			BEGIN
				SET @Result= 'G,'
			END
		ELSE
			BEGIN
				SET @Result = ''
			END
	
	SET @TEST = SUBSTRING(@Rating,2,1)
		IF(@TEST = 1)
			BEGIN
				SET @Result = @Result+ 'PG,'
			END
		ELSE
			BEGIN
				SET @Result = @Result
			END
	
	SET @TEST = SUBSTRING(@Rating,3,1)
		IF(@TEST=1)
			BEGIN
				SET @Result = @Result+ 'PG13,'
			END
		ELSE
			BEGIN
				SET @Result = @Result
			END

	SET @TEST = SUBSTRING(@Rating,4,1)
		IF(@TEST= 1)
			BEGIN
				SET @Result = @Result+ 'R,'
			END
		ELSE
			BEGIN
				SET @Result = @Result
			END

	SET @Length =  LEN(@Result) 
		
		SET @Result = STUFF ( @Result , @Length , @Length , '' )
		
	END
	RETURN @Result
END
