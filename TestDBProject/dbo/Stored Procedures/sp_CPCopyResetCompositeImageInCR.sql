-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_CPCopyResetCompositeImageInCR] 
	-- Add the parameters for the stored procedure here
	@CompositeCropStagingID INT,
	@CreativeCropStagingID INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	BEGIN TRY
	BEGIN TRANSACTION
    -- Insert statements for procedure here

	DECLARE @CompositeCropStagingIDNew AS INT
		-- Insert statements for procedure here
		INSERT INTO CompositeCropStaging
				([CreativeCropStagingID],
				[CropID],
				[Deleted])
		VALUES (@CreativeCropStagingID,	--/// this was set earlier
				NULL,
				0)

		SET @CompositeCropStagingIDNew = SCOPE_IDENTITY()

	INSERT INTO CropCategoryGroupStaging
				([CompositeCropStagingID],
				[CategoryGroupID])
	SELECT @CompositeCropStagingIDNew,	--/// this was set earlier
					[CategoryGroupID]
					FROM CropCategoryGroupStaging
					WHERE [CompositeCropStagingID] =@CompositeCropStagingID

	Select @CompositeCropStagingIDNew as NewCompCropID

	 COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
		SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
		RAISERROR ('[sp_CPCopyResetCompositeImageInCR]: %d: %s',16,1,@error,@message,@lineNo);
		ROLLBACK TRANSACTION
	END CATCH
END
