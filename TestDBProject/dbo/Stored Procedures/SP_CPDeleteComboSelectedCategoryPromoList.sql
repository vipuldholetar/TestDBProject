-- =============================================
-- Author:		Monika.J
-- Create date: 11/24/2015
-- Description:	To delete selected dta from Tables
-- =============================================
CREATE PROCEDURE SP_CPDeleteComboSelectedCategoryPromoList 
	-- Add the parameters for the stored procedure here
	@Val INT,
	@CategoryGroupName NVARCHAR(50),
	@CropStgID INT,
	@CreativeCropStgID INT,
	@CategoryID NVARCHAR(50),
	@PromotionID NVARCHAR(50),
	@ContentDetailStgID INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	BEGIN TRY
    -- Insert statements for procedure here
	BEGIN TRANSACTION  
	IF(@Val=1)
		BEGIN
		DECLARE @CategoryGroupID INT
		SET @CategoryGroupID = (SELECT [RefCategoryGroupID] from refCategoryGroup where CategoryGroupName=@CategoryGroupName)
		
			DELETE FROM CropCategoryGroupStaging
			WHERE [CompositeCropStagingID] = @CropStgID
			AND [CategoryGroupID] = @CategoryGroupID
	
			UPDATE [PromotionStaging]
				SET [DeletedInd] = 1
			FROM [PromotionStaging] a, RefCategory b
			WHERE a.[CompositeCropStagingID] = @CropStgID
			AND b.[RefCategoryID] = a.[CategoryID]
			AND b.[CategoryGroupID] = @CategoryGroupID
		END
	ELSE IF (@Val=2)
		BEGIN
		--For Category
		DECLARE @Category INT
		SET @Category = (select [RefCategoryID] from RefCategory where CategoryName=@CategoryID)
		
			UPDATE [PromotionStaging]
			SET [DeletedInd] = 1
			WHERE [CompositeCropStagingID] = @CropStgID
			AND [CategoryID] = @Category
		END

	ELSE IF(@Val=3)
		BEGIN
			--For Promotion
			DECLARE @Promotion INT
			SET @Promotion = (select [RefPromotionID] from RefPromotion where PromotionName=@PromotionID)
			DELETE FROM AdPromotionStaging
			WHERE [CreativeCropStagingID] = @CreativeCropStgID
			AND [RecordStagingID] = CASE WHEN RecordType = 'A' THEN @CreativeCropStgID	
										  WHEN RecordType = 'P' THEN @ContentDetailStgID
										  ELSE @CropStgID END
			AND [PromotionID] = @Promotion	
		END

	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH 
				  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
				  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				  RAISERROR ('SP_CPDeleteComboSelectedCategoryPromoList: %d: %s',16,1,@error,@message,@lineNo); 
				  ROLLBACK TRANSACTION
	END CATCH 
END