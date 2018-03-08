-- =============================================
-- Author		: Arun Nair
-- Create date	: 
-- Description	: Get AnsweredOn
-- Updated By	: 
--===================================================

CREATE FUNCTION [dbo].[fn_CheckAnsweredOn]
(
	@AnsweredOn DateTime,
	@RaisedOn DateTime
)
RETURNS Integer
AS
BEGIN

	DECLARE @Result Integer 

	IF(@AnsweredOn <> '')
		BEGIN

			Select @Result = Datediff(day, @RaisedOn, @AnsweredOn) From [QueryDetail]
		END

	ELSE
		BEGIN
			Select @Result = Datediff(day, @RaisedOn, Getdate()) From [QueryDetail]
		END

	RETURN @Result
END
