CREATE FUNCTION [dbo].[ConditionsResultToTRUE] (@MediaStream varchar, 
@IndustryGroupID int, 
@AdvertiserID int, 
@AdvertiserName varchar, 
@CategoryID int, 
@SubCategoryID int, 
@MarketID int, 
@RunDate date,
@LanguageID int,
@CriteriaID int) 
RETURNS @ConditionsTab TABLE 
	(
		ConditionID int
	)
AS 
BEGIN

	DECLARE @ConditionList NVARCHAR(MAX)		

	IF @CriteriaID is not NULL
	begin
		SET @ConditionList = (SELECT CASE WHEN CompoundORInd = 1
								THEN ConditionIDList
								ELSE ConditionID END 
							FROM [RefElementCriteriaCondition]
							WHERE [ElementCriteriaID] = @CriteriaID)
	end
	ELSE	
	begin
		set @ConditionList = (SELECT  ISNULL( STUFF
		(
			(SELECT ',' + CAST(RefElementConditionID AS VARCHAR)
			 FROM RefElementCondition
			 WHERE ExpireDT >= GETDATE()
			 FOR XML PATH('')
			)
		,1,1,''),' '))
	end

	IF (@MediaStream IS NOT NULL)	
	BEGIN
		INSERT INTO @ConditionsTab
		SELECT ElementConditionID
		FROM ElementCondition
		WHERE AdLevelVariable = 'MediaStream'
		AND  ElementConditionID  IN (Select Id from [dbo].[fn_CSVToTable] (@ConditionList))
		AND ConditionOperator = 'IN'
		AND @MediaStream IN (ConditionVariable)
		
		INSERT INTO @ConditionsTab
		SELECT ElementConditionID
		FROM ElementCondition
		WHERE AdLevelVariable = 'MediaStream'
		AND ElementConditionID  IN (Select Id from [dbo].[fn_CSVToTable] (@ConditionList))
		AND ConditionOperator = 'NOT IN'
		AND @MediaStream not in (ConditionVariable)
	END

	IF (@IndustryGroupID IS NOT NULL)
	BEGIN
		INSERT INTO @ConditionsTab
		SELECT ElementConditionID
		FROM ElementCondition
		WHERE AdLevelVariable = 'IndustryGroup'
		AND  ElementConditionID  IN (Select Id from [dbo].[fn_CSVToTable] (@ConditionList))
		AND ConditionOperator = 'IN'
		AND @IndustryGroupID IN (Select Id from [dbo].[fn_CSVToTable](ConditionVariable))
		
		INSERT INTO @ConditionsTab
		SELECT ElementConditionID
		FROM ElementCondition
		WHERE AdLevelVariable = 'IndustryGroup'
		AND ElementConditionID  IN (Select Id from [dbo].[fn_CSVToTable] (@ConditionList))
		AND ConditionOperator = 'NOT IN'
		AND @IndustryGroupID not in (Select Id from [dbo].[fn_CSVToTable](ConditionVariable))
	END

	IF (@AdvertiserID IS NOT NULL)
	BEGIN
		INSERT INTO @ConditionsTab
		SELECT ElementConditionID
		FROM ElementCondition
		WHERE AdLevelVariable = 'Advertiser'
		AND  ElementConditionID IN (Select Id from [dbo].[fn_CSVToTable] (@ConditionList))
		AND ConditionOperator = 'IN'
		AND @AdvertiserID in (Select Id from [dbo].[fn_CSVToTable](ConditionVariable))
		
		INSERT INTO @ConditionsTab
		SELECT ElementConditionID
		FROM ElementCondition
		WHERE AdLevelVariable = 'Advertiser'
		AND ElementConditionID IN (Select Id from [dbo].[fn_CSVToTable] (@ConditionList))
		AND ConditionOperator = 'NOT IN'
		AND @AdvertiserID not in (Select Id from [dbo].[fn_CSVToTable](ConditionVariable))
	END

	IF (@AdvertiserName IS NOT NULL)
	BEGIN
		INSERT INTO @ConditionsTab
		SELECT ElementConditionID
		FROM ElementCondition
		WHERE AdLevelVariable = 'AdvertiserName contains'
		AND  ElementConditionID IN (Select Id from [dbo].[fn_CSVToTable] (@ConditionList))
		AND ConditionOperator = 'IN' 
		AND ConditionVariable Like '%' + @AdvertiserName + '%'
	END

	IF (@CategoryID IS NOT NULL)
	BEGIN
		INSERT INTO @ConditionsTab
		SELECT ElementConditionID
		FROM ElementCondition
		WHERE AdLevelVariable = 'Category'
		AND  ElementConditionID IN (Select Id from [dbo].[fn_CSVToTable] (@ConditionList))
		AND ConditionOperator = 'IN'
		AND @CategoryID in (Select Id from [dbo].[fn_CSVToTable](ConditionVariable))
		
		INSERT INTO @ConditionsTab
		SELECT ElementConditionID
		FROM ElementCondition
		WHERE AdLevelVariable = 'Category'
		AND ElementConditionID IN (Select Id from [dbo].[fn_CSVToTable] (@ConditionList))
		AND ConditionOperator = 'NOT IN'
		AND @CategoryID not in (Select Id from [dbo].[fn_CSVToTable](ConditionVariable))
	END

	IF (@SubCategoryID IS NOT NULL)
	BEGIN
		INSERT INTO @ConditionsTab
		SELECT ElementConditionID
		FROM ElementCondition
		WHERE AdLevelVariable = 'SubCategory'
		AND  ElementConditionID IN (Select Id from [dbo].[fn_CSVToTable] (@ConditionList))
		AND ConditionOperator = 'IN'
		AND @SubCategoryID in (Select Id from [dbo].[fn_CSVToTable](ConditionVariable))
		
		INSERT INTO @ConditionsTab
		SELECT ElementConditionID
		FROM ElementCondition
		WHERE AdLevelVariable = 'SubCategory'
		AND ElementConditionID IN (Select Id from [dbo].[fn_CSVToTable] (@ConditionList))
		AND ConditionOperator = 'NOT IN'
		AND @SubCategoryID not in (Select Id from [dbo].[fn_CSVToTable](ConditionVariable))
	END

	IF (@MarketID IS NOT NULL)
	BEGIN
		INSERT INTO @ConditionsTab
		SELECT ElementConditionID
		FROM ElementCondition
		WHERE AdLevelVariable = 'TargetMarket'
		AND  ElementConditionID IN (Select Id from [dbo].[fn_CSVToTable] (@ConditionList))
		AND ConditionOperator = 'IN'
		AND @MarketID in (Select Id from [dbo].[fn_CSVToTable](ConditionVariable))
		
		INSERT INTO @ConditionsTab
		SELECT ElementConditionID
		FROM ElementCondition
		WHERE AdLevelVariable = 'TargetMarket'
		AND ElementConditionID IN (Select Id from [dbo].[fn_CSVToTable] (@ConditionList))
		AND ConditionOperator = 'NOT IN'
		AND @MarketID not in (Select Id from [dbo].[fn_CSVToTable](ConditionVariable))
	END

	IF (@RunDate IS NOT NULL)
	BEGIN
		INSERT INTO @ConditionsTab
		SELECT ElementConditionID
		FROM ElementCondition
		WHERE AdLevelVariable = 'ExpireDate'
		AND  ElementConditionID IN (Select Id from [dbo].[fn_CSVToTable] (@ConditionList))
		AND ConditionOperator = '='
		AND @RunDate between CAST(ConditionVariable as date) and CAST(ConditionVariable as date)
	END

	IF(@LanguageID IS NOT NULL)
	begin
		INSERT INTO @ConditionsTab
		SELECT ElementConditionID
		FROM ElementCondition
		WHERE AdLevelVariable = 'Language'
		AND  ElementConditionID IN (Select Id from [dbo].[fn_CSVToTable] (@ConditionList))
		AND ConditionOperator = 'IN'
		AND @LanguageID in (Select Id from [dbo].[fn_CSVToTable](ConditionVariable))
		
		INSERT INTO @ConditionsTab
		SELECT ElementConditionID
		FROM ElementCondition
		WHERE AdLevelVariable = 'Language'
		AND ElementConditionID IN (Select Id from [dbo].[fn_CSVToTable] (@ConditionList))
		AND ConditionOperator = 'NOT IN'
		AND @LanguageID not in (Select Id from [dbo].[fn_CSVToTable](ConditionVariable))
	END

RETURN
END