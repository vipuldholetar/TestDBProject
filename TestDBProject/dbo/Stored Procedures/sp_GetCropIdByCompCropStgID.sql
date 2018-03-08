CREATE PROCEDURE [dbo].[sp_GetCropIdByCompCropStgID] 
	@CompStgID INT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
	
	
	select cs.cropid from CompositeCropStaging cc join CompositeCropStaging cs on cc.CreativeCropStagingID = cs.CreativeCropStagingID
	where cc.CompositeCropStagingID = @CompStgID
	
	END TRY
	BEGIN CATCH
		DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
		SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
		RAISERROR ('[sp_GetCropIdByCompCropStgID]: %d: %s',16,1,@error,@message,@lineNo);
		
	END CATCH
END