CREATE PROCEDURE [dbo].[sp_GetAdById] 
	@AdID int
	
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY 
		SELECT * from Ad where AdId = @AdID
	END TRY
	BEGIN CATCH
		DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
		SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
		RAISERROR ('[sp_GetAdById]: %d: %s',16,1,@error,@message,@lineNo);
		ROLLBACK TRANSACTION
	END CATCH

END