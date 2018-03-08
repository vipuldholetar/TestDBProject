
CREATE PROCEDURE [dbo].[sp_CPDeleteCompleteStatusUpdateOnCrop]
	-- Add the parameters for the stored procedure here
	@Val INT,
	@CropID INT,
	@UserID INT,
	@CreativeCropID INT,
	@CreativeContentID INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	BEGIN TRY
	BEGIN TRANSACTION
		-- Insert statements for procedure here
		IF(@Val=1) --Delete Crop
			BEGIN
				UPDATE CompositeCropStaging SET [Deleted] = 1
				WHERE [CompositeCropStagingID] = @CropID				
			END
		ELSE IF(@Val=2) --Ad Complete
			BEGIN
				UPDATE [CreativeForCrop]
				SET [CompletedByID] = @UserID,
				[CompletedDT] = CURRENT_TIMESTAMP
				WHERE [CreativeForCropID] = @CreativeCropID
			END
		ELSE IF(@Val=3) --Page Complete
			BEGIN
			--Select @CreativeContentID = [CreativeContentDetailID] from CreativeContentDetail where [CreativeCropID]=@CreativeCropID
				UPDATE CreativeContentDetail
					SET [CompletedByID] = @UserID,
					[CompletedDT] = CURRENT_TIMESTAMP
					WHERE [CreativeContentDetailID] = @CreativeContentID
		--select * from CreativeContentDetail
			END
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
		SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
		RAISERROR ('[sp_CPDeleteCompleteStatusUpdateOnCrop]: %d: %s',16,1,@error,@message,@lineNo);		
		ROLLBACK TRANSACTION
	END CATCH
END