-- =============================================
-- Author:		Monika. J
-- Create date: 12/21/2015
-- Description:	to Get Category Group based on Product
-- sp_CPGetCategoryGroupByProductBased 1041,'tele','Test Product Name3'  --12078,12094   --12077,12096
-- =============================================
CREATE PROCEDURE sp_CPGetCategoryGroupByProductBased 
	-- Add the parameters for the stored procedure here
	@CropID INT,
	@Brand NVARCHAR(50),
	@Product NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @CreativeCropStgID INT
	DECLARE @CropStgID INT

	SELECT @CreativeCropStgID=[CreativeCropStagingID] from CompositeCropStaging where [CropID]=@CropID
	select @CropStgID=Max([CompositeCropStagingID]) from CompositeCropStaging where [CreativeCropStagingID]=@CreativeCropStgID AND ([Deleted]=0 Or [Deleted] IS NULL)
		
    -- Insert statements for procedure here
	IF(@Brand <> NULL OR @Brand <> '')
	BEGIN
		SELECT DISTINCT a.CategoryGroupName as CategoryUnSelectedLst, a.[RefCategoryGroupID]--,d.ProductName
		FROM RefCategoryGroup a LEFT JOIN refcategory b ON b.[CategoryGroupID]=a.[RefCategoryGroupID]
		LEFT JOIN  refSubCategory c on c.[CategoryID]=b.[RefCategoryID] 
		LEFT JOIN refProduct d ON d.[SubCategoryID]=c.[RefSubCategoryID] 
		WHERE a.[RefCategoryGroupID] NOT IN (SELECT DISTINCT a.[CategoryGroupID] FROM CropCategoryGroupStaging a INNER JOIN 
		CompositeCropStaging b ON b.[CompositeCropStagingID]=a.[CompositeCropStagingID] WHERE 
		a.[CompositeCropStagingID] NOT IN (select [RecordStagingID] FROM AdPromotionStaging where 
		[CreativeCropStagingID]=@CreativeCropStgID AND [RecordStagingID] <> @CropStgID) AND b.[CreativeCropStagingID]=@CreativeCropStgID )
		and a.CategoryGroupName like '%'+ @Brand +'%' 
		AND d.ProductName=@Product
	END
	ELSE
	BEGIN
		SELECT DISTINCT a.CategoryGroupName as CategoryUnSelectedLst, a.[RefCategoryGroupID]--,d.ProductName
		FROM RefCategoryGroup a LEFT JOIN refcategory b ON b.[CategoryGroupID]=a.[RefCategoryGroupID]
		LEFT JOIN  refSubCategory c on c.[CategoryID]=b.[RefCategoryID] 
		LEFT JOIN refProduct d ON d.[SubCategoryID]=c.[RefSubCategoryID] 
		WHERE a.[RefCategoryGroupID] NOT IN (SELECT DISTINCT a.[CategoryGroupID] FROM CropCategoryGroupStaging a INNER JOIN 
		CompositeCropStaging b ON b.[CompositeCropStagingID]=a.[CompositeCropStagingID] WHERE 
		a.[CompositeCropStagingID] NOT IN (select [RecordStagingID] FROM AdPromotionStaging where 
		[CreativeCropStagingID]=@CreativeCropStgID AND [RecordStagingID] <> @CropStgID) AND b.[CreativeCropStagingID]=@CreativeCropStgID )
		AND d.ProductName=@Product
	END

END
