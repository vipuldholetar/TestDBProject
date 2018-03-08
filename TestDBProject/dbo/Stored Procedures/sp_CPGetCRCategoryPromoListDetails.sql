CREATE PROCEDURE [dbo].[sp_CPGetCRCategoryPromoListDetails] --sp_CPGetCRCategoryPromoListDetails 32927,'Online Display',29715235,2047
	-- Add the parameters for the stored procedure here
	@AdID int,
	@MediaStream nvarchar(max),
	@UserID INT,
	@CropID INT
AS
BEGIN


	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
    SET NOCOUNT ON;
    BEGIN TRY
    DECLARE @MediaStreamValue As Nvarchar(max)=''	
    SELECT @MediaStreamValue=Value  FROM   [dbo].[Configuration] WHERE ValueTitle=@MediaStream
    DECLARE @OccurrenceID int
    SET @OccurrenceID = (Select [PrimaryOccurrenceID] from Ad where [AdID]=@AdID)
    
    DECLARE @CreativeCropStgID INT
	
    IF @CropID IS NULL OR @CropID = 0
    BEGIN
		SELECT @CreativeCropStgID = [CreativeCropStagingID],@CropID=CropID FROM CompositeCropStaging 
		WHERE [CreativeCropStagingID] IN(SELECT CreativeForCropStagingID FROM [CreativeForCropStaging] 
		   WHERE [CreativeCropID] IN(SELECT [CreativeForCropID] FROM [CreativeForCrop]
			  WHERE [CreativeID] = @AdID	AND [OccurrenceID] = @OccurrenceID))
		AND deleted = 0
    END
    ELSE
    BEGIN
    --SELECT @CropStgID=PK_ID,@CreativeCropStgID=FK_CreativeCropStagingID from CompositeCropStaging where FK_CropID=12
    SELECT @CreativeCropStgID=[CreativeCropStagingID] from CompositeCropStaging where [CropID]=@CropID
    END

	If(@OccurrenceID IS NOT NULL)
		BEGIN
			IF(@MediaStreamValue='CIR') 
			BEGIN
					SELECT d.Descrip as Advertiser,
					b.[CommonAdDT] as AdDate,
					e.Descrip as MTIndustry,
					h.Descrip + '/' + g.EditionName as PubEdition,
					f.[Descrip] as Market,
					a.[AdID] as AdID,
					a.[OccurrenceID] as OccurrenceID,
					@CropID as CropID 
					FROM [CreativeForCropStaging] a 
					INNER JOIN Ad b ON b.[AdID] = a.[AdID]
					INNER JOIN [OccurrenceDetailCIR] c ON c.[OccurrenceDetailCIRID] = a.[OccurrenceID]
					INNER JOIN [Advertiser] d ON d.[AdvertiserID] = b.[AdvertiserID]
					INNER JOIN MediaType e ON e.[MediaTypeID] = c.[MediaTypeID]
					INNER JOIN [Market] f ON f.[MarketID] = c.[MarketID]
					INNER JOIN PubEdition g ON g.[PubEditionID] = c.[PubEditionID]
					INNER JOIN Publication h ON h.[PublicationID] = g.[PublicationID] WHERE a.[LockedByID] = @UserID AND a.[AdID]=@AdID AND a.[OccurrenceID]=@OccurrenceID
			END
			ELSE IF(@MediaStreamValue='PUB')
			BEGIN
					SELECT d.Descrip as Advertiser,
					b.[CommonAdDT] as AdDate,
					e.Descrip as MTIndustry,
					h.Descrip + '/' + g.EditionName as PubEdition,
					f.[Descrip] as Market,
					a.[AdID] as AdID,
					a.[OccurrenceID] as OccurrenceID,
					@CropID as CropID 
					FROM [CreativeForCropStaging] a 
					INNER JOIN Ad b ON b.[AdID] = a.[AdID]
					INNER JOIN [OccurrenceDetailPUB] c ON c.[OccurrenceDetailPUBID] = a.[OccurrenceID]
					INNER JOIN [Advertiser] d ON d.[AdvertiserID] = b.[AdvertiserID]
					INNER JOIN MediaType e ON e.[MediaTypeID] = c.[MediaTypeID]
					INNER JOIN [Market] f ON f.[MarketID] = c.[MarketID]
					INNER JOIN PubIssue i ON i.[PubIssueID] = c.[PubIssueID]
					INNER JOIN PubEdition g ON g.[PubEditionID] = i.[PubEditionID]
					INNER JOIN Publication h ON h.[PublicationID] = g.[PublicationID] WHERE a.[LockedByID] = @UserID AND a.[AdID]=@AdID AND a.[OccurrenceID]=@OccurrenceID
			END
			ELSE
			BEGIN
				SELECT c.Descrip as Advertiser,
				    b.[CommonAdDT] as AdDate,
				    f.IndustryName as MTIndustry,
				    '' as PubEdition,
				    d.[Descrip] as Market,
				    a.[AdID] as AdID,
				    @OccurrenceID as OccurrenceID,
					@CropID as CropID 
				    from [CreativeForCropStaging] a 
				    INNER JOIN Ad b ON b.[AdID] = a.[AdID]
				    INNER JOIN [Market] d ON d.[MarketID] = b.[TargetMarketId]
				    INNER JOIN [Advertiser] c ON c.[AdvertiserID] = b.[AdvertiserID]
				    INNER JOIN AdvertiserIndustryGroup e ON e.[AdvertiserID] = c.[AdvertiserID]
				    INNER JOIN RefIndustryGroup f ON f.[RefIndustryGroupID] = e.[IndustryGroupID] WHERE a.[LockedByID] = @UserID AND a.[AdID]=@AdID
			END
		END
	ELSE
			BEGIN
				SELECT c.Descrip as Advertiser,
				b.[CommonAdDT] as AdDate,
				f.IndustryName as MTIndustry,
				'' as PubEdition,
				d.[Descrip] as Market,
				a.[AdID] as AdID,
				@OccurrenceID as OccurrenceID,
				@CropID as CropID  
				from [CreativeForCropStaging] a 
				INNER JOIN Ad b ON b.[AdID] = a.[AdID]
				INNER JOIN [Market] d ON d.[MarketID] = b.[TargetMarketId]
				INNER JOIN [Advertiser] c ON c.[AdvertiserID] = b.[AdvertiserID]
				INNER JOIN AdvertiserIndustryGroup e ON e.[AdvertiserID] = c.[AdvertiserID]
				INNER JOIN RefIndustryGroup f ON f.[RefIndustryGroupID] = e.[IndustryGroupID] WHERE a.[LockedByID] = @UserID AND a.[AdID]=@AdID
			END

	--Categories Assigned		select * from CreativeContentDetailStaging
		DECLARE @CropStgID INT
		DECLARE @ContentDetailStgID INT

		select @CropStgID=Max([CompositeCropStagingID]) from CompositeCropStaging where [CreativeCropStagingID]=@CreativeCropStgID AND (Deleted=0 Or Deleted IS NULL)
		--select @CropStgID
		SELECT @ContentDetailStgID=CreativeContentDetailStagingID FROM CreativeContentDetailStaging where CreativeCropStagingID=@CreativeCropStgID
				
		--SELECT DISTINCT d.CategoryGroupName, d.PK_ID FROM CreativeforCropStaging a INNER JOIN CompositeCropStaging b ON b.FK_CreativeCropStagingID = a.PK_ID
		--INNER JOIN CropCategoryGroupStaging c ON c.FK_CompositeCropStagingID = b.PK_ID INNER JOIN RefCategoryGroup d ON  d.PK_ID = c.FK_CategoryGroupID
		--WHERE a.LockedBy = @UserID AND b.PK_ID =@CropStgID

		SELECT DISTINCT d.CategoryGroupName, d.[RefCategoryGroupID] FROM [CreativeForCropStaging] a INNER JOIN CompositeCropStaging b ON b.[CreativeCropStagingID] = a.[CreativeForCropStagingID]
		INNER JOIN CropCategoryGroupStaging c ON c.[CompositeCropStagingID] = b.[CompositeCropStagingID] INNER JOIN RefCategoryGroup d ON  d.[RefCategoryGroupID] = c.[CategoryGroupID]		
		WHERE a.[LockedByID] = @UserID AND a.[CreativeForCropStagingID]=@CreativeCropStgID  AND 
		c.[CompositeCropStagingID] NOT IN (select [RecordStagingID] FROM AdPromotionStaging where [CreativeCropStagingID]=@CreativeCropStgID)
		UNION 
		SELECT DISTINCT d.CategoryGroupName, d.[RefCategoryGroupID] FROM [CreativeForCropStaging] a INNER JOIN CompositeCropStaging b ON b.[CreativeCropStagingID] = a.[CreativeForCropStagingID]
		INNER JOIN CropCategoryGroupStaging c ON c.[CompositeCropStagingID] = b.[CompositeCropStagingID] INNER JOIN RefCategoryGroup d ON  d.[RefCategoryGroupID] = c.[CategoryGroupID]
		WHERE a.[LockedByID] = @UserID AND b.[CompositeCropStagingID] =@CropStgID

		--SELECT CategoryGroupName as CategoryUnSelectedLst, PK_ID
		--FROM RefCategoryGroup WHERE PK_ID NOT IN (SELECT FK_CategoryGroupID FROM CropCategoryGroupStaging	WHERE FK_CompositeCropStagingID = @CropStgID)		

		SELECT CategoryGroupName as CategoryUnSelectedLst, [RefCategoryGroupID]
		FROM RefCategoryGroup  WHERE [RefCategoryGroupID] NOT IN (SELECT DISTINCT a.[CategoryGroupID] FROM CropCategoryGroupStaging a INNER JOIN CompositeCropStaging b ON b.[CompositeCropStagingID]=a.[CompositeCropStagingID] WHERE 
		a.[CompositeCropStagingID] NOT IN (select [RecordStagingID] FROM AdPromotionStaging where [CreativeCropStagingID]=@CreativeCropStgID AND [RecordStagingID] <> @CropStgID) AND b.[CreativeCropStagingID]=@CreativeCropStgID ) 
	
--	select distinct a.CategoryGroupName as CategoryUnSelectedLst, a.PK_ID from RefCategoryGroup a INNER JOIN refcategory b ON b.FK_CategoryGroupID=a.PK_ID
--INNER JOIN  refSubCategory c on c.FK_CategoryID=b.PK_ID 
--INNER JOIN refProduct d ON d.FK_SubCategoryID=c.PK_ID 
	
	
	--Promotions Assigned

		--/// For the whole Ad	
		
		SELECT c.PromotionName, --b.RecordType
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
		INNER JOIN CreativeContentDetailStaging c ON c.CreativeContentDetailStagingID = b.[RecordStagingID]
		INNER JOIN RefPromotion d ON d.[RefPromotionID] = b.[PromotionID] WHERE a.[LockedByID] = @UserID AND b.RecordType = 'P' AND a.[CreativeForCropStagingID]=@CreativeCropStgID--AND c.PK_ID = @CropStgID

		UNION ALL

		--/// For the specific Crop (i.e. Composite Image)	
		SELECT d.PromotionName, --b.RecordType
		CASE b.RecordType 
			WHEN 'A' THEN 'Whole AD' 
			  WHEN 'P' THEN 'Full Page'  
			  WHEN 'C' THEN 'Composite Image' 
			  ELSE b.RecordType  
			END as RecordType 
		FROM [CreativeForCropStaging] a INNER JOIN AdPromotionStaging b ON b.[CreativeCropStagingID] = a.[CreativeForCropStagingID]
		INNER JOIN CompositeCropStaging c ON c.[CompositeCropStagingID] = b.[RecordStagingID]
		INNER JOIN RefPromotion d ON d.[RefPromotionID] = b.[PromotionID] WHERE a.[LockedByID] = @UserID AND b.RecordType = 'C' AND c.[CompositeCropStagingID] = @CropStgID

		SELECT PromotionName, [RefPromotionID] FROM RefPromotion WHERE [RefPromotionID] NOT IN (SELECT [PromotionID] FROM AdPromotionStaging
		WHERE [CreativeCropStagingID] = @CreativeCropStgID AND (RecordType = 'A' OR ([RecordStagingID] = @ContentDetailStgID	AND RecordType = 'P')
		OR ([RecordStagingID] = @CropStgID	AND RecordType = 'C')))


		--Categories
		select DISTINCT d.CategoryName, d.RefCategoryID
		FROM [CreativeForCropStaging] a INNER JOIN CompositeCropStaging b ON b.[CreativeCropStagingID] = a.[CreativeForCropStagingID]
		INNER JOIN [PromotionStaging] c ON c.[CompositeCropStagingID] = b.[CompositeCropStagingID] AND (c.[DeletedInd] <> 1 OR c.[DeletedInd] IS NULL OR c.[DeletedInd]='')
		INNER JOIN RefCategory d ON d.[RefCategoryID] = c.[CategoryID] WHERE a.[LockedByID] = @UserID AND b.[CreativeCropStagingID] = @CreativeCropStgID AND 
		d.[CategoryGroupID] = (SELECT Top 1 d.[RefCategoryGroupID] FROM [CreativeForCropStaging] a INNER JOIN CompositeCropStaging b ON b.[CreativeCropStagingID] = a.[CreativeForCropStagingID]
		INNER JOIN CropCategoryGroupStaging c ON c.[CompositeCropStagingID] = b.[CompositeCropStagingID] INNER JOIN RefCategoryGroup d ON  d.[RefCategoryGroupID] = c.[CategoryGroupID]
		WHERE a.[LockedByID] = @UserID AND a.[CreativeForCropStagingID]=@CreativeCropStgID  AND 
		c.[CompositeCropStagingID] NOT IN (select [RecordStagingID] FROM AdPromotionStaging where [CreativeCropStagingID]=@CreativeCropStgID) )
		--select * from PromotionMasterStaging


END TRY
	BEGIN CATCH
		DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
		SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
		RAISERROR ('[sp_CPGetCRCategoryPromoListDetails]: %d: %s',16,1,@error,@message,@lineNo);
		
	END CATCH
END