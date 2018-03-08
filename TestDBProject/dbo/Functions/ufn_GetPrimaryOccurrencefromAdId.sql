-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[ufn_GetPrimaryOccurrencefromAdId]
(
	@AdID INT
)
RETURNS VARCHAR(200) with schemabinding 
AS
BEGIN
    DECLARE @VAL AS VARCHAR(200)

	SELECT TOP 1 @VAL = PrimaryOccurrenceID FROM dbo.Ad WHERE ADID = @ADID

	RETURN @VAL
END