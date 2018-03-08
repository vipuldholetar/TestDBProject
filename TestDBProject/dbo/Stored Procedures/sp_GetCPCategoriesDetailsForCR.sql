CREATE PROCEDURE [dbo].[sp_GetCPCategoriesDetailsForCR] 
	-- Add the parameters for the stored procedure here
	@UserID int,
	@CategoryGrpNm nvarchar(max),
	@CropID INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	BEGIN TRY
    -- Insert statements for procedure here
		DECLARE @CategoryGrpID INT
		select @CategoryGrpID=[RefCategoryGroupID] from RefCategoryGroup where CategoryGroupName=@CategoryGrpNm
		
		BEGIN
			select DISTINCT d.CategoryName,d.RefCategoryID
			FROM [CreativeForCropStaging] a INNER JOIN CompositeCropStaging b ON b.[CreativeCropStagingID] = a.[CreativeForCropStagingID]
			INNER JOIN [PromotionStaging] c ON c.[CompositeCropStagingID] = b.[CompositeCropStagingID] and c.[DeletedInd] <> 1
			INNER JOIN RefCategory d ON d.[RefCategoryID] = c.[CategoryID] 
			WHERE 
			c.[LockedByID] = @UserID 
			AND b.[CompositeCropStagingID] = @CropID AND 
			d.[CategoryGroupID] = @CategoryGrpID
		END

		BEGIN
			--select DISTINCT d.CategoryName
			--FROM CreativeforCrop a INNER JOIN CompositeCrop b ON b.FK_CreativeCropID = a.PK_ID
			--INNER JOIN PromotionMaster c ON c.FK_CropID = b.PK_ID
			--INNER JOIN RefCategory d ON d.PK_ID = c.FK_CategoryID WHERE  b.PK_ID = @CropID AND d.FK_CategoryGroupID = @CategoryGrpID

			Select DISTINCT CategoryName,RefCategoryID FROM RefCategory 
				WHERE 
				[RefCategoryID] NOT IN 
					   (select DISTINCT c.[CategoryID]
						FROM [CreativeForCropStaging] a INNER JOIN CompositeCropStaging b ON b.[CreativeCropStagingID] = a.[CreativeForCropStagingID]
						INNER JOIN [PromotionStaging] c ON c.[CompositeCropStagingID] = b.[CompositeCropStagingID] and c.[DeletedInd] <> 1
						INNER JOIN RefCategory d ON d.[RefCategoryID] = c.[CategoryID] 
						WHERE b.[CompositeCropStagingID] = @CropID AND d.[CategoryGroupID] = @CategoryGrpID) AND
					   [CategoryGroupID]=@CategoryGrpID
		END

	
	END TRY
	BEGIN CATCH
		DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
		SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
		RAISERROR ('[sp_GetCPCategoriesDetailsForCR]: %d: %s',16,1,@error,@message,@lineNo);
		
	END CATCH
END

