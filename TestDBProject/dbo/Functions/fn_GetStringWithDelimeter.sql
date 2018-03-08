-- =============================================
-- Author:		Suman Saurav
-- Create date: 06 Jan 2016
-- Description:	Created to ggenerate string with delimiter
-- =============================================
CREATE FUNCTION [dbo].[fn_GetStringWithDelimeter]
(
	@TABLE	dbo.TableType READONLY,
	@Separator CHAR(5)
)
RETURNS VARCHAR(500)
AS
BEGIN
	DECLARE @RETURN VARCHAR(500)
	SELECT @RETURN = COALESCE(@RETURN + @Separator ,'') + ColumnValue
	FROM @TABLE



	--SET @RETURN = stuff((
	--	SELECT @Separator + ColumnValue
	--	FROM @TABLE
	--	FOR XML PATH('')
	--),1 ,1 ,'')
	RETURN @RETURN
END
