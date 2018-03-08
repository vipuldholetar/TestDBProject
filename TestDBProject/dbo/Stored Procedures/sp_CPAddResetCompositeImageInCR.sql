-- =============================================
-- Author:		Monika. J
-- Create date: 11/16/15
-- Description:	To Insert new line in the Staging tables
-- =============================================
CREATE PROCEDURE [dbo].[sp_CPAddResetCompositeImageInCR] 
	-- Add the parameters for the stored procedure here
	@CreativeCropStagingID INT
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	BEGIN TRY
	BEGIN TRANSACTION
	DECLARE @CompositeCropStagingID AS INT
		-- Insert statements for procedure here
		INSERT INTO CompositeCropStaging
				([CreativeCropStagingID],
				[CropID],
				[Deleted])
		VALUES (@CreativeCropStagingID,	--/// this was set earlier
				NULL,
				0)

		SET @CompositeCropStagingID = SCOPE_IDENTITY()
		--IF(@Val=1)
		--BEGIN
		--	--/// Retain of the same Category Groups
		--	INSERT INTO CropCategoryGroupStaging
		--		(FK_CompositeCropStagingID,
		--		FK_CategoryGroupID)
		--	SELECT @CompositeCropStagingID,	--/// this was set earlier
		--			FK_CategoryGroupID
		--			FROM CropCategoryGroupStaging
		--			WHERE FK_CompositeCropStagingID =@PrecCompCropID --<previous viewed CompositeCropStagingID>)
		--END

		Select @CompositeCropStagingID as NewCompCropID
		 COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
		SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
		RAISERROR ('[sp_CPAddResetCompositeImageInCR]: %d: %s',16,1,@error,@message,@lineNo);
		ROLLBACK TRANSACTION
	END CATCH
END
