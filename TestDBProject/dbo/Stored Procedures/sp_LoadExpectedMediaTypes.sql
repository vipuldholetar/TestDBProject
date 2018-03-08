create PROCEDURE [dbo].[sp_LoadExpectedMediaTypes]
	(
@MediaStreamId AS NVARCHAR(MAX)
)
AS
SET NOCOUNT ON;
BEGIN
	BEGIN TRY
		SELECT distinct Descrip,[MediaTypeID] FROM MediaType Inner Join Expectation on MediaType.MediaTypeID=Expectation.MediaID WHERE MediaStream = @MediaStreamId AND IndDisplayValue = 1 ORDER BY 1
	END TRY
	BEGIN CATCH 
		DECLARE @error   INT,@message VARCHAR(4000), @lineNo  INT 
		SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line()
		RAISERROR ('[sp_LoadExpectedMediaTypes]: %d: %s',16,1,@error,@message,@lineNo); 
	END CATCH 
END