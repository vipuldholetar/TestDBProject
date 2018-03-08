CREATE FUNCTION [dbo].[GetSizeText] 
(
	@SizeId int
)
RETURNS VARCHAR(15)
AS
BEGIN
	DECLARE @Result VARCHAR(15)
	DECLARE @height FLOAT
	DECLARE @width FLOAT
	DECLARE @heightText VARCHAR(5) 
	DECLARE @widthText VARCHAR(5)


	SELECT @height=Height, @width=Width
	FROM [Size]
	WHERE [SizeID]=@SizeId

	-- For, Height
	SET @heightText = REPLICATE('0', 5-LEN(CAST(@height AS NUMERIC(5,2)))) + CAST(CAST(@height AS NUMERIC(5,2)) AS VARCHAR)

	-- For, Width
	SET @widthText = REPLICATE('0', 5-LEN(CAST(@width AS NUMERIC(5,2)))) + CAST(CAST(@width AS NUMERIC(5,2)) AS VARCHAR)


	SET @Result = @widthText + ' X ' + @heightText


	-- Return the result of the function
	RETURN @Result
END
