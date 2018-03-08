-- =============================================
-- Author:		Suman Saurav
-- Create date: 30 Dec 2015
-- Description:	Created to get selected row values and display at bottom
--EXE	EXEC [sp_CPReviewQueueSelectedRowInfo]  2159, 0, 1, 1, 0, 'PE'
-- =============================================
CREATE PROCEDURE [dbo].[sp_CPReviewQueueSelectedRowInfo]
(
	@AdID				INT,
	@CropId				INT,
	@CategoryID			INT,
	@CategoryGroupID	INT,
	@PromoTemplateId	INT,
	@AuditType			NVARCHAR(2)
)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		DECLARE @Description VARCHAR(50) = '', @ValueTitle VARCHAR(50) = '', @ClassifiedBy VARCHAR(50) = '', @CategoryGroupName VARCHAR(50) = '', 
				@CategoryName VARCHAR(50) = '', @AuditedByOn VARCHAR(50) = '', @PromoEnteredByOn VARCHAR(50) = '', @CroppedByOn VARCHAR(50) = '',
				@AuditTypeAC_CreatedBy INT = 0, @AuditTypeAC_CreatedBy1 INT = 0, @AuditTypeCR_CreatedBy INT = 0, @AuditTypeCR_CreatedBy1 INT = 0,
				@AuditTypePE_CreatedBy INT = 0, @ClassifiedByID INT = 0
		SELECT @Description = b.[Descrip] FROM Ad a, [Market] b WHERE a.[AdID] = @AdID AND b.[MarketID] = a.[TargetMarketId]
		SELECT @ClassifiedBy = b.Username + '/' + CONVERT(VARCHAR(25), a.[ClassifiedDT]), @ClassifiedByID = a.ClassifiedBy FROM Ad a, [User] b WHERE a.ClassifiedBy = b.UserId AND [AdvertiserID] = @AdID
		SELECT @CategoryGroupName = b.CategoryGroupName FROM CropCategoryGroup a, RefCategoryGroup b WHERE a.[CropCategoryGroupID] = @CropId AND
				b.[RefCategoryGroupID] = a.[CategoryGroupID] OR (@AuditType = 'PE' AND a.[CategoryGroupID] != @CategoryGroupID)
		SELECT @CategoryName = b.CategoryName FROM [Promotion] a, RefCategory b WHERE a.[CropID] = @CropId AND b.[RefCategoryID] = a.[CategoryID]
				OR (@AuditType = 'PE' AND a.AuditType = @AuditType AND a.[CategoryID] != @CategoryID)
		SELECT @CroppedByOn = b.Username + '/' + CONVERT(VARCHAR(25), a.[CreatedDT]) FROM CompositeCrop a, [User] b WHERE a.[CompositeCropID] = @CropId
		SELECT @PromoEnteredByOn = b.Username + '/' + CONVERT(VARCHAR(25), a.[CreatedDT]) FROM [Promotion] a, [User] b WHERE b.UserId = a.[CreatedByID] AND [PromotionID] = @PromoTemplateId
		SELECT @AuditedByOn = b.Username + '/' + CONVERT(VARCHAR(25), a.[AuditDT]) FROM Ad a, [User] b WHERE b.UserId = a.[AuditedByID] AND a.[AdID] = @AdID
		-- For AuditType = “AC”
		SELECT @AuditTypeAC_CreatedBy = CreatedBy, @AuditTypeAC_CreatedBy1 = ClassifiedBy FROM Ad WHERE [AdID] = @AdID
		-- For AuditType = “CR”
		SELECT @AuditTypeCR_CreatedBy = a.[CreatedByID], @AuditTypeCR_CreatedBy1 =b.[CompletedByID] FROM  CompositeCrop a
			INNER JOIN [CreativeForCrop] b ON b.[CreativeForCropID] = a.[CreativeCropID]
			INNER JOIN Ad c ON c.[AdID] = b.[CreativeID]
			-- For AuditType = “PE”
		SELECT @AuditTypePE_CreatedBy = a.[CreatedByID] FROM [Promotion] a 
		INNER JOIN Ad b ON a.[AdvertiserID] = b.[AdvertiserID] AND b.[AdID] = @AdId AND a.[CropID] = @CropId		

		SELECT @Description AS Description, @ClassifiedBy AS ClassifiedBy, @CategoryGroupName AS CategoryGroupName, @CategoryName AS CategoryName, 
		@CroppedByOn AS CroppedByOn, @PromoEnteredByOn AS PromoEnteredByOn, @AuditedByOn AS AuditedByOn, @AuditTypeAC_CreatedBy AS AuditTypeAC_CreatedBy,
		@AuditTypeAC_CreatedBy1 AS AuditTypeAC_CreatedBy1, @AuditTypeCR_CreatedBy AS AuditTypeCR_CreatedBy, @AuditTypeCR_CreatedBy1 AS AuditTypeCR_CreatedBy1,
		@AuditTypePE_CreatedBy AS AuditTypePE_CreatedBy, @ClassifiedByID AS ClassifiedByID
	END TRY
	BEGIN CATCH
		DECLARE @error INT, @message NVARCHAR(4000), @lineNo INT 
		SELECT @error = Error_number(), @message = Error_message(), @lineNo = Error_line() 
		RAISERROR ('[sp_CPReviewQueueSelectedRowInfo]: %d: %s', 16, 1, @error, @message, @lineNo);
	END CATCH
END