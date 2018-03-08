CREATE FUNCTION [dbo].[fn_GetAllConditionsResultingToTrue] (@AdID INT, @ConditionTitle VARCHAR(MAX))
RETURNS VARCHAR(MAX)
AS
BEGIN
	
	DECLARE @VALUE VARCHAR(1000)

	IF REPLACE(@ConditionTitle,CHAR(13)+CHAR(10),'') = 'MediaStream'
			  BEGIN
			  SELECT @Value = MediaStream
			  FROM [Pattern] 
			  WHERE [AdID] = @AdID
	END

	ELSE IF REPLACE(@ConditionTitle,CHAR(13)+CHAR(10),'') = 'IndustryGroup'
			BEGIN
			SELECT @Value = b.[IndustryGroupID]
			FROM Ad a, AdvertiserIndustryGroup b
			WHERE b.[AdvertiserID] = a.[AdvertiserID]
			AND a.[AdID] = @AdID
	END		

	ELSE IF REPLACE(@ConditionTitle,CHAR(13)+CHAR(10),'') = 'Advertiser'
			BEGIN
			SELECT @Value = [AdvertiserID]
			FROM Ad
			WHERE [AdID] = @AdID
	END

	ELSE IF REPLACE(@ConditionTitle,CHAR(13)+CHAR(10),'') = 'AdvertiserName'
			BEGIN
			SELECT @Value = b.Advertiser
			FROM Ad a, [AdvertiserOld] b
			WHERE b.[AdvertiserID] = a.[AdvertiserID]
			AND a.[AdID] = @AdID
	END

	ELSE IF REPLACE(@ConditionTitle,CHAR(13)+CHAR(10),'') = 'Category'
			BEGIN
			SELECT @Value = c.[CategoryID]
			FROM Ad a, RefProduct b, RefSubCategory c
			WHERE b.[RefProductID] = a.ProductId
			AND c.[RefSubCategoryID] = b.[SubCategoryID]
			AND a.[AdID] = @AdID
	END

	ELSE IF REPLACE(@ConditionTitle,CHAR(13)+CHAR(10),'') = 'SubCategory'
			BEGIN
			SELECT @Value = b.[SubCategoryID]
			FROM Ad a, RefProduct b
			WHERE b.[RefProductID] = a.ProductID
			AND a.[AdID] = @AdID
	END

	ELSE IF REPLACE(@ConditionTitle,CHAR(13)+CHAR(10),'') = 'MarketID'
			BEGIN
			SELECT @Value = [TargetMarketId]
			FROM Ad
			WHERE [AdID] = @AdID
	END

	ELSE IF REPLACE(@ConditionTitle,CHAR(13)+CHAR(10),'') = 'FirstRunDate'
			BEGIN
			SELECT @Value = CONVERT(VARCHAR(MAX),FirstRunDate)
			FROM Ad
			WHERE [AdID] = @AdID
	END
	RETURN @VALUE
END