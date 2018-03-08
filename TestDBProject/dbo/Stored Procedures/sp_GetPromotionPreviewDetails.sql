CREATE PROCEDURE [dbo].[sp_GetPromotionPreviewDetails] 
	 @RecordID INT,
	 @CropID INT,
	 @CategoryID INT,
	 @CategoryGroupID INT,
	 @KeyID INT
AS 
  BEGIN 
      BEGIN TRY 

	  -- Variable declaration
	  DECLARE @AdFirstRunDate DATETIME,
			  @CreatedByOn VARCHAR(50),
			  @MediaStrem VARCHAR(10),
			  @Language VARCHAR(10),
			  @IndexedByOn NVARCHAR(MAX),
			  @CategoryGroupAndCategory NVARCHAR(MAX),
			  @OtherCategoryGroups VARCHAR(MAX),
			  @OtherCategories VARCHAR(MAX),
			  @CroppedByOn VARCHAR(MAX),
			  @PromoRecordCount INT,
			  @PromoQAndA VARCHAR(MAX)
			  
	  --Ad First Run Date, Create By/On, Language

	  SELECT @AdFirstRunDate=Ad.FirstRunDate,@CreatedByOn= (US.FName+ ' / ' + Convert(Varchar(20),Ad.CreateDate)) 
	  ,@Language=LM.Description
	  FROM AD left JOIN [Language] LM ON AD.[LanguageID]= LM.LanguageID
	  left JOIN [User] US ON Ad.CreatedBy=US.UserID
	  WHERE Ad.[AdID] = @RecordID

	  --Other Category Groups

	 
SET @OtherCategoryGroups = ''
      SELECT DISTINCT  b.CategoryGroupName as CGM INTO #Temp 
      FROM CropCategoryGroup a, RefCategoryGroup b
	  WHERE a.[CropCategoryGroupID] = @CropID
	  AND a.[CategoryGroupID] != @CategoryGroupID
	  AND b.[RefCategoryGroupID] = a.[CategoryGroupID]
      SELECT  @OtherCategoryGroups = @OtherCategoryGroups + CGM + '/'
      FROM #Temp
      drop table #Temp
	

	  --Other Categories

	  SELECT @OtherCategories=b.CategoryName
	  FROM [Promotion] a, RefCategory b
	  WHERE a.[CropID] = @CropID
	  AND a.[CategoryID] != @CategoryID
	  AND b.[RefCategoryID] = a.[CategoryID]

	  --Cropped By/On
	  SELECT @CroppedByOn=(US.UserName + ' / ' + CONVERT(VARCHAR(MAX),[CreatedDT],103))
	  FROM CompositeCrop CC left JOIN [User] US ON CC.[CreatedByID]=US.UserID
	  WHERE CC.[CompositeCropID] = @CropID

	  --Promo Q&A
	
	  SELECT @PromoQAndA=(b.ValueTitle + '|' + a.QueryText + '|' + a.[QryAnswer])
	  FROM [QueryDetail] a, SystemConfiguration b
	  WHERE a.[PromoID] = @KeyID	--selected row’s KeyID
	  AND a.System = 'C&P'
	  AND a.EntityLevel = 'PRO'
	  AND b.SystemName = 'All'
	  AND b.ComponentName = 'Query Category'
	  AND b.Value = a.QueryCategory


	  SELECT @AdFirstRunDate AS AdFirstRunDate,@CreatedByOn AS CreatedByOn,@MediaStrem AS MediaStrem,@Language AS Language,@IndexedByOn AS IndexedByOn
			,@CategoryGroupAndCategory AS CategoryGroupAndCategory,@OtherCategoryGroups AS OtherCategoryGroups,@OtherCategories AS OtherCategories
			,@CroppedByOn AS CroppedByOn,@PromoRecordCount AS PromoRecordCount,@PromoQAndA AS PromoQAndA


      END TRY 

      BEGIN CATCH 

          DECLARE @error   INT,
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('sp_GetPromotionPreviewDetails: %d: %s',16,1,@error,@message,@lineNo); 
		  
      END catch; 

  END;
