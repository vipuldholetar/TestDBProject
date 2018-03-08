-- =============================================
-- Author:		Monika. J
-- Create date: 12-11-2015
-- Description:	To Get Add Pix Combo Details
-- Execution: sp_CPGetAddPixCatePromoDetailFromCR 29712222,12124
-- =============================================
CREATE PROCEDURE [dbo].[sp_CPGetAddPixCatePromoDetailFromCR] 
	-- Add the parameters for the stored procedure here
	@UserID INT,
	@CropStgID INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	BEGIN TRY
		
		DECLARE @CreativeCropStgID INT
		DECLARE @ContentDetailStgID INT		

		SELECT @CreativeCropStgID=[CreativeCropStagingID] from CompositeCropStaging where [CompositeCropStagingID]=@CropStgID
		SELECT @ContentDetailStgID=[CreativeContentDetailStagingID] FROM CreativeContentDetailStaging where [CreativeCropStagingID]=@CreativeCropStgID

    -- Insert statements for procedure here
		--SELECT DISTINCT d.CategoryGroupName, d.PK_ID FROM CreativeforCropStaging a INNER JOIN CompositeCropStaging b ON b.FK_CreativeCropStagingID = a.PK_ID
		--INNER JOIN CropCategoryGroupStaging c ON c.FK_CompositeCropStagingID = b.PK_ID INNER JOIN RefCategoryGroup d ON  d.PK_ID = c.FK_CategoryGroupID
		--WHERE a.LockedBy = @UserID AND b.PK_ID =@CropStgID

		SELECT DISTINCT d.CategoryGroupName, d.[RefCategoryGroupID] FROM [CreativeForCropStaging] a INNER JOIN CompositeCropStaging b ON b.[CreativeCropStagingID] = a.[CreativeForCropStagingID]
		INNER JOIN CropCategoryGroupStaging c ON c.[CompositeCropStagingID] = b.[CompositeCropStagingID] INNER JOIN RefCategoryGroup d ON  d.[RefCategoryGroupID] = c.[CategoryGroupID]		
		WHERE a.[LockedByID] = @UserID AND a.[CreativeForCropStagingID]=@CreativeCropStgID  AND 
		c.[CompositeCropStagingID] NOT IN (select [RecordStagingID] FROM AdPromotionStaging where [CreativeCropStagingID]=@CreativeCropStgID)
		--AND b.PK_ID =@CropStgID select * from AdPromotionStaging  select * from CompositeCropStaging select * from CropCategoryGroupStaging		
		
		SELECT CategoryGroupName as CategoryUnSelectedLst, [RefCategoryGroupID]
		FROM RefCategoryGroup  WHERE [RefCategoryGroupID] NOT IN (SELECT DISTINCT a.[CategoryGroupID] FROM CropCategoryGroupStaging a INNER JOIN CompositeCropStaging b ON b.[CompositeCropStagingID]=a.[CompositeCropStagingID] WHERE 
		a.[CompositeCropStagingID] NOT IN (select [RecordStagingID] FROM AdPromotionStaging where [CreativeCropStagingID]=@CreativeCropStgID) AND b.[CreativeCropStagingID]=@CreativeCropStgID ) 
		--FK_CompositeCropStagingID = @CropStgID)	
		

		SELECT c.PromotionName,-- b.RecordType,
		CASE b.RecordType 
			WHEN 'A' THEN 'Whole AD' 
			  WHEN 'P' THEN 'Full Page'  
			  WHEN 'C' THEN 'Composite Image' 
			  ELSE b.RecordType  
			END as RecordType 

		FROM [CreativeForCropStaging] a INNER JOIN AdPromotionStaging b ON b.[RecordStagingID] = a.[CreativeForCropStagingID] INNER JOIN RefPromotion c ON c.[RefPromotionID] = b.[PromotionID] 
		WHERE a.[LockedByID] = @UserID AND b.RecordType = 'A' AND a.[CreativeForCropStagingID]=@CreativeCropStgID
		
		UNION ALL

		--/// For the full Page		
		SELECT d.PromotionName, --b.RecordType
		CASE b.RecordType 
			WHEN 'A' THEN 'Whole AD' 
			  WHEN 'P' THEN 'Full Page'  
			  WHEN 'C' THEN 'Composite Image' 
			  ELSE b.RecordType  
			END as RecordType 
		FROM [CreativeForCropStaging] a INNER JOIN AdPromotionStaging b ON b.[CreativeCropStagingID] = a.[CreativeForCropStagingID]
		INNER JOIN CreativeContentDetailStaging c ON c.[CreativeContentDetailStagingID] = b.[RecordStagingID]
		INNER JOIN RefPromotion d ON d.[RefPromotionID] = b.[PromotionID] WHERE a.[LockedByID] = @UserID AND b.RecordType = 'P' AND a.[CreativeForCropStagingID]=@CreativeCropStgID--c.PK_ID = @CropStgID

		--UNION ALL

		----/// For the specific Crop (i.e. Composite Image)	
		--SELECT d.PromotionName, b.RecordType
		--FROM CreativeforCropStaging a INNER JOIN AdPromotionStaging b ON b.FK_CreativeCropStagingID = a.PK_ID
		--INNER JOIN CompositeCropStaging c ON c.PK_ID = b.FK_RecordStagingID
		--INNER JOIN RefPromotion d ON d.PK_ID = b.FK_PromotionID WHERE a.LockedBy = @UserID AND b.RecordType = 'C' AND c.PK_ID = @CropStgID

		SELECT PromotionName, [RefPromotionID] FROM RefPromotion WHERE [RefPromotionID] NOT IN (SELECT [PromotionID] FROM AdPromotionStaging
		WHERE [CreativeCropStagingID] = @CreativeCropStgID AND (RecordType = 'A' OR ([RecordStagingID] = @ContentDetailStgID	AND RecordType = 'P')))
		--OR (FK_RecordStagingID = @CropStgID	AND RecordType = 'C')))

		select DISTINCT d.CategoryName
		FROM [CreativeForCropStaging] a INNER JOIN CompositeCropStaging b ON b.[CreativeCropStagingID] = a.[CreativeForCropStagingID]
		INNER JOIN [PromotionStaging] c ON c.[CompositeCropStagingID] = b.[CompositeCropStagingID] AND (c.[DeletedInd] <> 1 OR c.[DeletedInd] IS NULL OR c.[DeletedInd]='')
		INNER JOIN RefCategory d ON d.[RefCategoryID] = c.[CategoryID] WHERE a.[LockedByID] = @UserID AND b.[CreativeCropStagingID] = @CreativeCropStgID AND d.[CategoryGroupID] = (SELECT Top 1 d.[RefCategoryGroupID] FROM [CreativeForCropStaging] a INNER JOIN CompositeCropStaging b ON b.[CreativeCropStagingID] = a.[CreativeForCropStagingID]
		INNER JOIN CropCategoryGroupStaging c ON c.[CompositeCropStagingID] = b.[CompositeCropStagingID] INNER JOIN RefCategoryGroup d ON  d.[RefCategoryGroupID] = c.[CategoryGroupID]
		WHERE a.[LockedByID] = @UserID AND b.[CompositeCropStagingID] =@CropStgID )
	END TRY
	BEGIN CATCH
		DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
		SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
		RAISERROR ('[sp_CPGetCRCategoryPromoListDetails]: %d: %s',16,1,@error,@message,@lineNo);
		
	END CATCH
END