-- =============================================
-- Author:		Suman Saurav
-- Create date: 29 Dec 2015
-- Description:	Used to update Ad, CompositeCrop, PromotionMaster on AuditComplete click.
-- =============================================
CREATE PROCEDURE [dbo].[sp_CPReviewQueueAuditComplete]
(
	@AuditType			VARCHAR(2),
	@UserId				INT,
	@AdId				INT,
	@CropId				INT,
	@PromoTemplateID	INT
)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRAN
			IF(@AuditType = 'AC')
			BEGIN
				UPDATE Ad SET [AuditedByID] = @UserID, [AuditDT] = CURRENT_TIMESTAMP WHERE [AdID] = @AdId
			END
			ELSE IF(@AuditType = 'CR')
			BEGIN
				UPDATE CompositeCrop SET AuditedBy = @UserID, [AuditedDT] = CURRENT_TIMESTAMP WHERE [CompositeCropID] = @CropId 
			END
			ELSE IF(@AuditType = 'PE')
			BEGIN
				UPDATE [Promotion] SET AuditedBy = @UserID, [AuditedDT] = CURRENT_TIMESTAMP WHERE [PromotionID] = @PromoTemplateID
			END
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		DECLARE @error INT, @message NVARCHAR(4000), @lineNo INT 
		SELECT @error = Error_number(), @message = Error_message(), @lineNo = Error_line() 
		RAISERROR ('[sp_CPReviewQueueAuditComplete]: %d: %s', 16, 1, @error, @message, @lineNo);
		ROLLBACK TRAN
	END CATCH
END
