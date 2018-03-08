-- =============================================
-- Author:		Monika.J
-- Create date: 10-20-2015
-- Description:	To Get Promo Details for the AdID and OccurrenceID
-- =============================================
CREATE PROCEDURE [dbo].[sp_CPGetCRWorkQueuePromoDetailsdata] --[sp_CPGetCRWorkQueuePromoDetailsdata] 6298,'2034','CIR'
	-- Add the parameters for the stored procedure here
	@AdID int,
	@OccurrenceID int,
	@MediaStream nvarchar(50)
AS
BEGIN
	BEGIN TRY
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @AddOcc AS NVARCHAR(MAX)
	DECLARE @Stmnt AS NVARCHAR(max)=''
		DECLARE @SelectStmnt AS NVARCHAR(max)='' 
		DECLARE @Where AS NVARCHAR(max)='' 
		DECLARE @Q_AValue NVARCHAR(MAX)
		DECLARE @MediaType NVARCHAR(MAX)
		DECLARE @tempTable table
		
			(
				RowId int IDENTITY(1,1),
				Score int,
				AdDate datetime,
				CropID int,
				CategoryGroup nvarchar(max),
				Category nvarchar(max),
				CropSize int,
				LastRunDate datetime,
				CroppedByOn nvarchar(250),
				KeyID int,
				CategoryGroupID int,
				CategoryID int
			)
     --Insert statements for procedure here
		if(@OccurrenceID <> '')
			BEGIN								
				SET @Q_AValue =(Select DISTINCT b.ValueTitle + ' | ' + a.QueryText + ' | ' + a.[QryAnswer]
				FROM [QueryDetail] a, [Configuration] b
				WHERE b.SystemName = 'All'
				AND b.ComponentName = 'Query Category'
				AND b.Value = a.QueryCategory
				AND a.System = 'C&P' AND a.[OccurrenceID] = @OccurrenceID AND a.EntityLevel = 'OCC')
				--SET @Q_AValue =1
				IF(@MediaStream = 'Circular')
				BEGIN
					SET @MediaType =(SELECT b.Descrip FROM [OccurrenceDetailCIR] a, MediaType b WHERE b.[MediaTypeID] = a.[MediaTypeID]
					AND a.[OccurrenceDetailCIRID] = @OccurrenceID)
				END
				ELSE IF(@MediaStream='Publication')
				BEGIN
					SET @MediaType=(SELECT b.Descrip FROM [OccurrenceDetailPUB] a, MediaType b WHERE b.[MediaTypeID] = a.[MediaTypeID]
					AND a.[OccurrenceDetailPUBID] = @OccurrenceID)
				END
				--ELSE 
					--SET @MediaType='Value'
			END
		ELSE 
			BEGIN
				SET @Q_AValue =(Select DISTINCT b.ValueTitle + ' | ' + a.QueryText + ' | ' + a.[QryAnswer]
				FROM [QueryDetail] a, [Configuration] b
				WHERE b.SystemName = 'All'
				AND b.ComponentName = 'Query Category'
				AND b.Value = a.QueryCategory
				AND a.System = 'C&P' AND a.[AdID] = @AdID AND a.EntityLevel = 'AD')
				SET @MediaType=''
				--SET @Q_AValue =0
			END

			
		INSERT INTO @tempTable(AdDate,CropID,CategoryGroup,Category,CropSize,LastRunDate,CroppedByOn,KeyID,CategoryGroupID,CategoryID)
			select DISTINCT 		
			--100 as Score,
			a.AdDate as AdDate,
			b.[CompositeCropID] as CropID,
			e.CategoryGroupName as CategoryGroup,
			f.CategoryName as Category,	--/// possible NULL value
			b.CompositeImageSize as CropSize,			
			c.LastRunDate,
			CONCAT((h.FNAME+' '+h.LNAME) ,SPACE(1), b.[CreatedDT]) AS CroppedByOn,
			--CONCAT((select DISTINCT a.FNAME+' '+a.LNAME from [User] a,CompositeCrop b where a.UserID=b.CreatedBy) ,SPACE(1), b.CreatedDate) AS CroppedByOn,			
			d.[PromotionID] as KeyID,
			f.[CategoryGroupID] as CategoryGroupID,
			d.[CategoryID] as CategoryID from [CreativeForCrop] a INNER JOIN CompositeCrop b ON b.[CreativeCropID] = a.[CreativeForCropID]
			INNER JOIN Ad c ON c.[AdID] = a.[CreativeID] INNER JOIN [Promotion] d ON d.[CropID] = b.[CompositeCropID]
			INNER JOIN CropCategoryGroup g ON g.[CropCategoryGroupID] = b.[CompositeCropID] INNER JOIN RefCategory f ON f.[RefCategoryID] = d.[CategoryID]
			INNER JOIN RefCategoryGroup e ON e.[RefCategoryGroupID] = g.[CategoryGroupID]
			LEFT JOIN [User] h ON h.UserID=b.[CreatedByID]
			 where a.[CreativeID] = @AdID 	 
			 
			 AND ISNULL(a.[OccurrenceID],'') = ISNULL(@OccurrenceID,'')


		
		

		--ORDER BY AdDate --Score, AdDate	--/// default sort order
			DECLARE @TopCount INT ,@Counter INT
			SET @TopCount=1
			SELECT @Counter=count(RowId) FROM @tempTable
			WHILE (@Counter>0)

			BEGIN
				DECLARE @LastRunDate  Datetime

				SELECT @LastRunDate = LastRunDate FROM @tempTable WHERE RowId=@TopCount

				IF(DATEPART(dw, getdate()) IN (2,3,4,5) AND Day(getdate()) between 8 and 15 AND @LastRunDate >= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0) and  @LastRunDate<=DATEADD(MONTH, DATEDIFF(MONTH, -1, GETDATE())-1, -1))
				 Update @tempTable SET Score=200
				 ELSE IF(@LastRunDate between DATEADD(week, DATEDIFF(week, 7, getdate()), 0) AND DATEADD(week, DATEDIFF(week, 7, getdate()), 6))
				 Update @tempTable SET Score=100
				 ELSE IF(@LastRunDate between DATEADD(week, DATEDIFF(week, 0, getdate()), 0) AND DATEADD(week, DATEDIFF(week, 0, getdate()), 6))
				 Update @tempTable SET Score=250
				 ELSE IF(@LastRunDate > getdate())
				 Update @tempTable SET Score=300
				 ELSE 
				 Update @tempTable SET Score=999

				select @Counter=@Counter-1
				select @TopCount=@TopCount+1
			END

			Select  *,@Q_AValue as QA,@MediaType as MediaType from @tempTable ORDER BY Score, AdDate

	END TRY
BEGIN CATCH 
			  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
			  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			  RAISERROR ('sp_CPGetCRWorkQueuePromoDetailsdata: %d: %s',16,1,@error,@message,@lineNo); 
			  
END CATCH 
END
