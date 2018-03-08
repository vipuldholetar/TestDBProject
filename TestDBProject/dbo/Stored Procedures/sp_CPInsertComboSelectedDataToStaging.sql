-- =============================================
-- Author:		Monika. J
-- Create date: 11/16/15
-- Description:	Insert combo inserted data to staging tables
-- Execution:  sp_CPInsertComboSelectedDataToStaging 3,7,'Test Category Name,Test Category Name2',850016455,'Whole AD','BOGO',4,2
-- =============================================
CREATE PROCEDURE [dbo].[sp_CPInsertComboSelectedDataToStaging] 
	-- Add the parameters for the stored procedure here
	@ID int,
	@CropStgID INT,
	@CategoryGrpID NVARCHAR(MAX),
	@UserID INT,
	@RecordType Nvarchar(50),
	@PromotionID NVARCHAR(MAX),
	@CreativeCropStgID INT,
	@CreativeContentStgID INT,
	@CropId INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF(@RecordType='Whole AD')
		SET @RecordType = 'A'
	ELSE IF(@RecordType='Full Page')
		SET @RecordType = 'P'
	ELSE IF(@RecordType='Composite Image')
		SET @RecordType = 'C'

	DECLARE @CategoryGrpTable TABLE (CompositeCropID INT,Item NVARCHAR(1000))
	DECLARE @CategoriesTable TABLE (CompositeCropID INT,Item NVARCHAR(1000))
	IF(@ID=1)
		BEGIN
		-- Insert statements for procedure here
		INSERT INTO @CategoryGrpTable (Item)
		SELECT * FROM  [dbo].[FN_CPSplitString] (@CategoryGrpID)

		INSERT INTO CropCategoryGroupStaging
		([CompositeCropStagingID],	[CategoryGroupID])
		SELECT @CropStgID,b.[RefCategoryGroupID] FROM @CategoryGrpTable a INNER JOIN refCategoryGroup b ON b.CategoryGroupName=a.Item 
		where b.[RefCategoryGroupID] NOT IN (Select [CategoryGroupID] from CropCategoryGroupStaging where [CompositeCropStagingID]=@CropStgID)
		--VALUES (@CropID,@CategoryGrpID) select * from PromotionMasterStaging
		END
	ELSE IF(@ID=2)
		BEGIN
		INSERT INTO @CategoriesTable (Item)
		SELECT * FROM  [dbo].[FN_CPSplitString] (@CategoryGrpID)

		INSERT INTO [PromotionStaging]
		([CompositeCropStagingID],CompositeCropID,[CategoryID],[LockedByID],[LockedDT])
		--VALUES (@CropID,@Categories)
		SELECT @CropStgID, @CropId , b.[RefCategoryID],@UserID,CURRENT_TIMESTAMP FROM @CategoriesTable a INNER JOIN RefCategory b ON b.CategoryName=a.Item
		where b.[RefCategoryID] NOT IN (Select [CategoryID] from [PromotionStaging] where [CompositeCropStagingID]=@CropStgID and [DeletedInd] IS NULL)
		END
	ELSE IF(@ID=3)
		BEGIN
		DECLARE @Promotion INT
			SET @Promotion = (select [RefPromotionID] from RefPromotion where PromotionName=@PromotionID)
			IF (NOT EXISTS(Select * from AdPromotionStaging where [PromotionID]=@Promotion AND [CreativeCropStagingID]=@CreativeCropStgID))
			BEGIN
				INSERT INTO AdPromotionStaging
				([CreativeCropStagingID],
				[RecordStagingID],
				RecordType,
				[PromotionID])
				VALUES (@CreativeCropStgID,
				CASE WHEN @RecordType = 'A' THEN @CreativeCropStgID
				WHEN @RecordType = 'P' THEN @CreativeContentStgID
				ELSE @CropStgID END,
				@RecordType,
				@Promotion)
			END
		END
	
END