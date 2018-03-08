CREATE PROCEDURE [dbo].[sp_GetCroppedDataFromStagingByCompCropStg] 
	@CropStgID INT,
	@id int,
	@type varchar(50)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
	
	DECLARE @CreativeCropStgID INT

	if len(@type) = 0
	begin
		select @CreativeCropStgID = ContentDetailStagingID from CropDetailIncludeStaging where CompositeCropStagingID = @CropStgID

		select * from CreativeContentDetailStaging where CreativeContentDetailStagingID = @CreativeCropStgId
		select * from CropDetailIncludeStaging where CompositeCropStagingID = @CropStgID
		select * from CropDetailExcludeStaging where ContentDetailStagingId = @CreativeCropStgId
	end
	else
	begin
		select * from CreativeContentDetailStaging where CreativeContentDetailStagingID = @id
		select * from CropDetailIncludeStaging where ContentDetailStagingID = @id
		select * from CropDetailExcludeStaging where ContentDetailStagingID = @id
	end
	
	END TRY
	BEGIN CATCH
		DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
		SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
		RAISERROR ('[sp_GetCroppedDataFromStagingByCompCropStg]: %d: %s',16,1,@error,@message,@lineNo);
		
	END CATCH
END