CREATE PROCEDURE [dbo].[sp_GetMediaStreamByAdId] 
	@AdID int
	
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY 

		select MediaStream from Pattern where AdId = @AdId
	
	END TRY
	BEGIN CATCH
		DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
		SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
		RAISERROR ('[sp_GetMediaStreamByAdId]: %d: %s',16,1,@error,@message,@lineNo);
		ROLLBACK TRANSACTION
	END CATCH

END