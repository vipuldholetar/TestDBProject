CREATE FUNCTION fn_CINCreativeName
(
	@AdName VARCHAR(200)
)
RETURNS VARCHAR(MAX)
AS
BEGIN

	DECLARE @Result VARCHAR(MAX)

	IF(@AdName<>'')
	BEGIN
		
		SET	@Result = REPLACE(@AdName, '.trp', '')

	END

	RETURN @Result
END
