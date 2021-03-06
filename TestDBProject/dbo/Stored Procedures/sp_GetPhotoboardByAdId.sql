﻿
CREATE PROCEDURE [dbo].[sp_GetPhotoboardByAdId] 
	@AdId int
	
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY 
		select * from Photoboard where AdID = @AdId
	END TRY
	BEGIN CATCH
		DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
		SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
		RAISERROR ('[sp_GetPhotoboardById]: %d: %s',16,1,@error,@message,@lineNo);
		ROLLBACK TRANSACTION
	END CATCH

END