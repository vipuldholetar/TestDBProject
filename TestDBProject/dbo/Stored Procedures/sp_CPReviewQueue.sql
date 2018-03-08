-- =============================================

-- Author		:	Suman Saurav

-- Create date	:	12/21/2015

-- Description	:	Used to retreive all the information regarding review queue.

-- exec sp_CPReviewQueue 0,0,0,'1/1/2015','12/30/2015', 0, 0, '', 0

-- =============================================

CREATE PROCEDURE [dbo].[sp_CPReviewQueue]

(

	@PromoTemplateID	INT,	-- applies to Promo Record level

	@CategoryGroupID	INT,	

	@UserID				INT,

	@RunDateFrom		VARCHAR(20),

	@RunDateTo			VARCHAR(20),

	@IncludeAudit		BIT = 0,

	@AdID				INT = 0,

	@Value				VARCHAR(50) = '',

	@CropId				INT = 0

)

AS

BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets

	SET NOCOUNT ON;

	BEGIN TRY

		-- For ClASsified Ads

		SELECT RecordID, Advertiser, RunDate, [Media Type/Industry], Status, [Category Group], Category, Product, [Product Description], [Promo Price], 

			[Audit Type], [Audit By/On], AdId, OccurrenceID, MediaStream, CategoryGroupID, CropID, CategoryID, PromoMasterID, Media

		FROM

		(

			SELECT a.[AdID] AS RecordID, b.Descrip AS Advertiser, a.FirstRunDate AS RunDate, d.IndustryName AS [Media Type/Industry], 'TBD' AS Status, h.CategoryGroupName AS [Category Group], 

			g.CategoryName AS Category, e.ProductName AS Product, NULL AS [Product Description], NULL AS [Promo Price],'AC' AS [Audit Type], US.Username + '/' + CONVERT(VARCHAR(25), a.[AuditDT]) AS [Audit By/On],

			--below columns are not for display

			a.[AdID] AS AdId, a.[PrimaryOccurrenceID] AS OccurrenceID, CM.ValueTitle AS MediaStream, h.[RefCategoryGroupID] AS CategoryGroupID, NULL AS CropID,

			g.[RefCategoryID] AS CategoryID, NULL AS PromoMasterID, CM.Value AS Media

			FROM Ad a

			INNER JOIN [Advertiser] b ON b.[AdvertiserID] = a.[AdvertiserID]

			INNER JOIN AdvertiserIndustryGroup c ON b.[AdvertiserID] = c.[AdvertiserID]

			INNER JOIN RefIndustryGroup d ON d.[RefIndustryGroupID] = c.[IndustryGroupID]

			INNER JOIN RefProduct e ON e.[RefProductID] = a.ProductId

			INNER JOIN RefSubCategory f ON f.[RefSubCategoryID] = e.[SubCategoryID]

			INNER JOIN RefCategory g ON g.[RefCategoryID] = f.[CategoryID]

			INNER JOIN RefCategoryGroup h ON h.[RefCategoryGroupID] = g.[CategoryGroupID]

			INNER JOIN [Pattern] PM ON PM.[AdID]=A.[AdID]

			INNER JOIN [Creative] CRM ON CRM.PK_ID=PM.[CreativeID]  

			INNER JOIN [Configuration] CM ON CM.CONFIGURATIONID=PM.MediaStream

			LEFT OUTER JOIN [User] US on us.UserId = a.[AuditedByID]

			WHERE @CategoryGroupID IS NOT NULL

				AND (h.[ClassificationGroupID] = @CategoryGroupID OR @CategoryGroupID = 0)

				AND (@RunDateFrom IS NOT NULL AND a.FirstRunDate >= @RunDateFrom) 

				AND (@RunDateTo IS NOT NULL AND a.LastRunDate <= @RunDateTo)

				AND (((CASE WHEN a.[AuditedByID] IS NULL THEN 0 ELSE 1 END) = (CASE @IncludeAudit WHEN 0 THEN 0 ELSE 1 END)) or (a.[AuditedByID] IS NULL))

		

			UNION ALL

			--SELECT TOP 10 * FROM ad

			--SELECT * FROM RefCategoryGroup

			--SELECT * FROM RefCategory

			--SELECT * FROM RefProduct

			--SELECT * FROM PromotionMaster

			--For CompositeCrops

			SELECT a.[CompositeCropID] AS RecordID, d.descrip AS Advertiser, b.AdDate AS RunDate, NULL AS [Media Type/Industry], 'TBD' AS Status,

			'multi' AS [Category Group], 'multi' AS Category, 'multi' AS Product, 'multi' AS [Product Description], 'multi' AS [Promo Price],

			--CASE WHEN 1 < (SELECT COUNT(*) FROM RefCategoryGroup) THEN ''

			--ELSE (SELECT CategoryGroupName FROM RefCategoryGroup) END AS [Category Group],



			--CASE WHEN 1 < (SELECT COUNT(*) FROM RefCategory) THEN ''

			--ELSE (SELECT CategoryName FROM RefCategory) END AS Category, 



			--CASE WHEN 1 < (SELECT COUNT(*) FROM RefProduct) THEN ''

			--ELSE (SELECT ProductName FROM RefProduct) END AS Product, 



			--CASE WHEN 1 < (SELECT COUNT(*) FROM PromotionMaster) THEN ''

			--ELSE (SELECT ProductDescription FROM PromotionMaster) END AS [Product Description],

			

			--CASE WHEN 1 < (SELECT COUNT(*) FROM PromotionMaster) THEN 0

			--ELSE (SELECT PromoPrice FROM PromotionMaster) END AS [Promo Price], 



			'CR' AS [Audit Type], US.Username + '/' + CONVERT(VARCHAR(25), c.[AuditDT]) AS [Audit By/On],			

			--below columns are not for display

			b.[CreativeID] AS AdId, b.[OccurrenceID] AS OccurrenceID, i.ValueTitle AS MediaStream, NULL AS CategoryGroupID, a.[CompositeCropID] AS CropID,

			NULL AS CategoryID,	NULL AS PromoMasterID, i.Value AS Media

			FROM CompositeCrop a

			INNER JOIN [CreativeForCrop] b ON b.[CreativeForCropID] = a.[CreativeCropID]

			INNER JOIN Ad c ON c.[AdID] = b.[CreativeID]

			INNER JOIN [Advertiser] d ON d.[AdvertiserID] = c.[AdvertiserID]

			INNER JOIN [Promotion] e ON e.[PromotionID] = c.[AdID]

			INNER JOIN RefCategory f ON e.[PromotionID] = f.[RefCategoryID] 

			INNER JOIN RefCategoryGroup g ON f.[CategoryGroupID] = g.[RefCategoryGroupID] 

			INNER JOIN RefProduct h ON e.[PromotionID] = h.[RefProductID]

			INNER JOIN [Configuration] i ON b.MediaStream = i.ConfigurationID

			LEFT OUTER JOIN [User] US on us.UserId = c.[AuditedByID]

			WHERE @CategoryGroupID IS NOT NULL 

				AND (@RunDateFrom IS NOT NULL AND b.AdDate >= @RunDateFrom) 

				AND (@RunDateTo IS NOT NULL AND b.AdDate <= @RunDateTo)

				AND (((CASE WHEN a.AuditedBy IS NULL THEN 0 ELSE 1 END) = (CASE @IncludeAudit WHEN 0 THEN 0 ELSE 1 END)) or (a.AuditedBy IS NULL))



			UNION ALL

			-- For Promo Records

			SELECT a.[PromotionID] AS RecordID, b.Descrip AS Advertiser, c.AdDate AS RunDate, NULL AS [Media Type/Industry], 'TBD 'AS Status, e.CategoryGroupName AS CategoryGroup, d.CategoryName AS [Category Group],

			f.ProductName AS Product, a.[ProductDescrip] AS [Product Description], 'TBD 'AS [Promo Price],'PE' AS [Audit Type], US.Username + '/' + CONVERT(VARCHAR(25), a.[AuditedDT]) AS [Audit By/On],

			c.[CreativeID] AS AdID, c.[OccurrenceID] AS OccurrenceID, i.ValueTitle AS MediaStream, e.[RefCategoryGroupID] AS CategoryGroupID, a.[CropID] as CropID,

			a.[CategoryID] AS CategoryID, a.[PromotionID] AS PromoMasterID, i.Value AS Media



			FROM [Promotion] a

			INNER JOIN [Advertiser] b ON b.[AdvertiserID] = a.[AdvertiserID]

			INNER JOIN [CreativeForCrop] c ON c.[CreativeForCropID] = a.[CropID]

			INNER JOIN RefCategory d ON d.[RefCategoryID] = a.[CategoryID]

			INNER JOIN RefCategoryGroup e ON e.[RefCategoryGroupID] = d.[CategoryGroupID]

			LEFT OUTER JOIN [User] US on us.UserId = a.AuditedBy

			INNER JOIN [Configuration] i ON c.MediaStream = i.ConfigurationID

			RIGHT OUTER JOIN RefProduct f ON f.[RefProductID] = a.[ProductID]



			WHERE @PromoTemplateID IS NOT NULL

				AND (d.[KETemplateID] = @PromoTemplateID OR @PromoTemplateID = 0) AND @CategoryGroupID IS NOT NULL

				AND (e.[RefCategoryGroupID] = @CategoryGroupID OR @CategoryGroupID = 0)

				AND @RunDateFrom IS NOT NULL AND @RunDateTo IS NOT NULL

				AND (c.AdDate >= @RunDateFrom AND c.AdDate <= @RunDateTo)

				AND (((CASE WHEN a.AuditedBy IS NULL THEN 0 ELSE 1 END) = (CASE @IncludeAudit WHEN 0 THEN 0 ELSE 1 END)) or (a.AuditedBy IS NULL))

		

			) AS T

		ORDER BY RunDate, RecordID

	END TRY

	BEGIN CATCH

		DECLARE @error INT, @message NVARCHAR(4000), @lineNo INT 

		SELECT @error = Error_number(), @message = Error_message(), @lineNo = Error_line() 

		RAISERROR ('[sp_CPReviewQueue]: %d: %s', 16, 1, @error, @message, @lineNo);

	END CATCH

END

-------Monika---

------New Script:

------Insert data to Creativeforcrop table:

----INSERT INTO [CreativeForCrop] ([CreativeID],[OccurrenceID],[CreativeMasterID],MediaStream,AdDate) 
----    values(31793,580079,39269,151,'2016-02-12 00:00:00.000')
----INSERT INTO [CreativeForCrop] ([CreativeID],[OccurrenceID],[CreativeMasterID],MediaStream,AdDate) 
----    values(31797,580081,39279,151,'2016-02-12 00:00:00.000')
----INSERT INTO [CreativeForCrop] ([CreativeID],[OccurrenceID],[CreativeMasterID],MediaStream,AdDate) 
----    values(31798,580082,39280,151,'2016-02-12 00:00:00.000')
----INSERT INTO [CreativeForCrop] ([CreativeID],[OccurrenceID],[CreativeMasterID],MediaStream,AdDate) 
----    values(31799,580083,39281,151,'2016-02-12 00:00:00.000')
----INSERT INTO [CreativeForCrop] ([CreativeID],[OccurrenceID],[CreativeMasterID],MediaStream,AdDate) 
----    values(31800,580084,39282,151,'2016-02-12 00:00:00.000')
----INSERT INTO [CreativeForCrop] ([CreativeID],[OccurrenceID],[CreativeMasterID],MediaStream,AdDate) 
----    values(31802,1080093,39285,152,'2016-02-12 00:00:00.000')

------Insert data to compositecrop table:

---- INSERT INTO Compositecrop ([CreativeCropID],[CreatedDT],[CreatedByID])
----   Values(1029,'2016-02-12',29712222)
---- INSERT INTO Compositecrop ([CreativeCropID],[CreatedDT],[CreatedByID])
----   Values(1030,'2016-02-12',29712222)
---- INSERT INTO Compositecrop ([CreativeCropID],[CreatedDT],[CreatedByID])
----   Values(1031,'2016-02-12',29712222)
---- INSERT INTO Compositecrop ([CreativeCropID],[CreatedDT],[CreatedByID])
----   Values(1032,'2016-02-12',29712222)
---- INSERT INTO Compositecrop ([CreativeCropID],[CreatedDT],[CreatedByID])
----   Values(1033,'2016-02-12',29712222)
---- INSERT INTO Compositecrop ([CreativeCropID],[CreatedDT],[CreatedByID])
----   Values(1034,'2016-02-12',29712222)

------Insert INTO Creativecontentdetail table:

---- INSERT INTO Creativecontentdetail ([CreativeCropID],[CreativeDetailID],SellableSpaceCoordX1,SellableSpaceCoordY1,SellableSpaceCoordX2,SellableSpaceCoordY2,SellableSpaceArea,[CreatedDT],[CreatedByID])
----   VALUES(1029,23672,0,0,0,0,0,'2015-02-12 13:33:43.600',29712222)
---- INSERT INTO Creativecontentdetail ([CreativeCropID],[CreativeDetailID],SellableSpaceCoordX1,SellableSpaceCoordY1,SellableSpaceCoordX2,SellableSpaceCoordY2,SellableSpaceArea,[CreatedDT],[CreatedByID])
----   VALUES(1030,23676,0,0,0,0,0,'2015-02-12 13:33:43.600',29712222)
---- INSERT INTO Creativecontentdetail ([CreativeCropID],[CreativeDetailID],SellableSpaceCoordX1,SellableSpaceCoordY1,SellableSpaceCoordX2,SellableSpaceCoordY2,SellableSpaceArea,[CreatedDT],[CreatedByID])
----   VALUES(1031,23677,0,0,0,0,0,'2015-02-12 13:33:43.600',29712222)
---- INSERT INTO Creativecontentdetail ([CreativeCropID],[CreativeDetailID],SellableSpaceCoordX1,SellableSpaceCoordY1,SellableSpaceCoordX2,SellableSpaceCoordY2,SellableSpaceArea,[CreatedDT],[CreatedByID])
----   VALUES(1032,23678,0,0,0,0,0,'2015-02-12 13:33:43.600',29712222)
---- INSERT INTO Creativecontentdetail ([CreativeCropID],[CreativeDetailID],SellableSpaceCoordX1,SellableSpaceCoordY1,SellableSpaceCoordX2,SellableSpaceCoordY2,SellableSpaceArea,[CreatedDT],[CreatedByID])
----   VALUES(1033,23679,0,0,0,0,0,'2015-02-12 13:33:43.600',29712222)
---- INSERT INTO Creativecontentdetail ([CreativeCropID],[CreativeDetailID],SellableSpaceCoordX1,SellableSpaceCoordY1,SellableSpaceCoordX2,SellableSpaceCoordY2,SellableSpaceArea,[CreatedDT],[CreatedByID])
----   VALUES(1034,15393,0,0,0,0,0,'2015-02-12 13:33:43.600',29712222)

------Insert INTO CreativeDetailInclude table:

---- INsert INTO CreativeDetailInclude (FK_CRopID,FK_ContentDetailID,CropRectCoordX1,CropRectCoordY1,CropRectCoordX2,CropRectCoordY2,CropDetailSize,[CreatedByID],[CreatedDT])
----   VALUES(2043,2013,10,10,10,10,1211,29712222,'2016-02-12 07:27:11.800')
---- INsert INTO CreativeDetailInclude (FK_CRopID,FK_ContentDetailID,CropRectCoordX1,CropRectCoordY1,CropRectCoordX2,CropRectCoordY2,CropDetailSize,[CreatedByID],[CreatedDT])
----   VALUES(2044,2014,10,10,10,10,1211,29712222,'2016-02-12 07:27:11.800')
---- INsert INTO CreativeDetailInclude (FK_CRopID,FK_ContentDetailID,CropRectCoordX1,CropRectCoordY1,CropRectCoordX2,CropRectCoordY2,CropDetailSize,[CreatedByID],[CreatedDT])
----   VALUES(2045,2015,10,10,10,10,1211,29712222,'2016-02-12 07:27:11.800')
---- INsert INTO CreativeDetailInclude (FK_CRopID,FK_ContentDetailID,CropRectCoordX1,CropRectCoordY1,CropRectCoordX2,CropRectCoordY2,CropDetailSize,[CreatedByID],[CreatedDT])
----   VALUES(2046,2016,10,10,10,10,1211,29712222,'2016-02-12 07:27:11.800')
---- INsert INTO CreativeDetailInclude (FK_CRopID,FK_ContentDetailID,CropRectCoordX1,CropRectCoordY1,CropRectCoordX2,CropRectCoordY2,CropDetailSize,[CreatedByID],[CreatedDT])
----   VALUES(2047,2017,10,10,10,10,1211,29712222,'2016-02-12 07:27:11.800')
---- INsert INTO CreativeDetailInclude (FK_CRopID,FK_ContentDetailID,CropRectCoordX1,CropRectCoordY1,CropRectCoordX2,CropRectCoordY2,CropDetailSize,[CreatedByID],[CreatedDT])
----   VALUES(2048,2018,10,10,10,10,1211,29712222,'2016-02-12 07:27:11.800')

------Insert into promotionmaster table:

----  INSERT INTO [Promotion] ([CropID],[CategoryID],[AdvertiserID],[ProductID],[CreatedDT],[CreatedByID])
----   values(2043,1,1,1,'2016-01-2 00:00:00.000',29712222)
---- INSERT INTO [Promotion] ([CropID],[CategoryID],[AdvertiserID],[ProductID],[CreatedDT],[CreatedByID])
----   values(2044,1,1,1,'2016-01-2 00:00:00.000',29712222)
---- INSERT INTO [Promotion] ([CropID],[CategoryID],[AdvertiserID],[ProductID],[CreatedDT],[CreatedByID])
----   values(2045,1,1,1,'2016-01-2 00:00:00.000',29712222)
---- INSERT INTO [Promotion] ([CropID],[CategoryID],[AdvertiserID],[ProductID],[CreatedDT],[CreatedByID])
----   values(2046,1,1,1,'2016-01-2 00:00:00.000',29712222)
---- INSERT INTO [Promotion] ([CropID],[CategoryID],[AdvertiserID],[ProductID],[CreatedDT],[CreatedByID])
----   values(2047,1,1,1,'2016-01-2 00:00:00.000',29712222)
---- INSERT INTO [Promotion] ([CropID],[CategoryID],[AdvertiserID],[ProductID],[CreatedDT],[CreatedByID])
----   values(2048,1,1,1,'2016-01-2 00:00:00.000',29712222)

------Insert into CropCategoryGroup table:

---- INSERT INTO Cropcategorygroup ([CropCategoryGroupID],[CategoryGroupID],[CreateDT],[CreatedByID])
----    VALUES(2043,1,'2016-01-2 00:00:00.000',297122221)
---- INSERT INTO Cropcategorygroup ([CropCategoryGroupID],[CategoryGroupID],[CreateDT],[CreatedByID])
----    VALUES(2044,1,'2016-01-2 00:00:00.000',297122221)
---- INSERT INTO Cropcategorygroup ([CropCategoryGroupID],[CategoryGroupID],[CreateDT],[CreatedByID])
----    VALUES(2045,1,'2016-01-2 00:00:00.000',297122221)
---- INSERT INTO Cropcategorygroup ([CropCategoryGroupID],[CategoryGroupID],[CreateDT],[CreatedByID])
----    VALUES(2046,1,'2016-01-2 00:00:00.000',297122221)
---- INSERT INTO Cropcategorygroup ([CropCategoryGroupID],[CategoryGroupID],[CreateDT],[CreatedByID])
----    VALUES(2047,1,'2016-01-2 00:00:00.000',297122221)
---- INSERT INTO Cropcategorygroup ([CropCategoryGroupID],[CategoryGroupID],[CreateDT],[CreatedByID])
----    VALUES(2048,1,'2016-01-2 00:00:00.000',297122221)

------vw_Promotionworkqueue:
----Update vw_Promotionworkqueue SET [ModifiedByID]=29712222

------Ad Table:
----Update Ad SET ProductId=8