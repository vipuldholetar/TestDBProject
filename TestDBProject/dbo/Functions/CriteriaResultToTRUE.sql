CREATE FUNCTION [dbo].[CriteriaResultToTRUE] (@MediaStream varchar, 
@IndustryGroupID int, 
@AdvertiserID int, 
@AdvertiserName varchar, 
@CategoryID int, 
@SubCategoryID int, 
@MarketID int, 
@RunDate date,
@LanguageID int,
@CriteriaID int,
@AdId INT)
RETURNS int
as
BEGIN

	

	DECLARE @Criteria TABLE 
	(
		CriteriaID int,
		CriteriaCount int
	)


		           insert into @Criteria
				   SELECT TBL.CriteriaID, COUNT(*) 
				   FROM (SELECT DISTINCT a.CriteriaID,b.[ElementCriteriaConditionID] 
						 FROM ElementCriteria a, 
							  [RefElementCriteriaCondition] b, 
							  ConditionsResultToTRUE(@MediaStream, @IndustryGroupID, @AdvertiserID, @AdvertiserName, @CategoryID, @SubCategoryID, @MarketID, @RunDate, @LanguageID, @CriteriaID) c 
							  WHERE a.CriteriaID = b.[ElementCriteriaID]
   							  AND a.CriteriaID = @CriteriaID or @CriteriaID is null
							  AND ((CompoundORInd = 0 AND c.ConditionID = b.ConditionID) OR
							      (CompoundORInd = 1 AND c.ConditionID  in (Select Id from [dbo].[fn_CSVToTable](b.ConditionIDList))))) AS TBL
							  GROUP BY TBL.CriteriaID 
							  HAVING count(*) = (SELECT COUNT(*) FROM [RefElementCriteriaCondition] x 
							  WHERE x.[ElementCriteriaID] = TBL.CriteriaID)


	if((select count(*) from @Criteria) > 0)
	begin

		IF NOT EXISTS (SELECT * FROM Photoboard WHERE AdID = @AdId AND Deleted = 0)
		begin
			return 1
		END 
	end
	return 0
end