-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[ufn_GetCSfromAdId]
(
	@AdID INT
)
RETURNS VARCHAR(200) with schemabinding 
AS
BEGIN
    DECLARE @VAL AS VARCHAR(200)

	SELECT TOP 1 @VAL = CreativeSignature FROM dbo.Pattern WHERE ADID = @ADID

	RETURN @VAL
END
