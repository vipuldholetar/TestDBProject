CREATE PROCEDURE [dbo].[sp_ClassificationAdData] --sp_ClassificationAdData 4208
	-- Add the parameters for the stored procedure here
	@AdID int
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	BEGIN TRY 
    -- Select statement to get Ad Details
		BEGIN TRANSACTION
		
				SELECT a.Campaign, a.KeyVisualElement,a.TaglineID,a.[CelebrityID],	a.ProductId, a.[TargetMarketId] as MarketId,				
					--(SELECT DISTINCT b.[RefIndustryGroupID] FROM AdvertiserIndustryGroup a, RefIndustryGroup b,Ad c 
					--WHERE a.[AdvertiserID] = c.[AdvertiserID] AND b.[RefIndustryGroupID] = a.[IndustryGroupID]) AS IndustryName,
					'' AS IndustryName,a.ClassificationGroupID,
					(SELECT DISTINCT b.[ClassificationGroupID] FROM AdvertiserIndustryGroup a, RefIndustryGroup b, Ad c
					 WHERE a.[AdvertiserID] = c.[AdvertiserID] AND b.[RefIndustryGroupID] = a.[IndustryGroupID] and c.adid = @AdID) as FK_ClassificationGroupID, 				
					(select DISTINCT d.[RefCategoryGroupID] FROM RefProduct a, RefSubCategory b, RefCategory c, RefCategoryGroup d, Ad e 
					 WHERE a.[RefProductID] = e.ProductId AND b.[RefSubCategoryID] = a.[SubCategoryID] AND c.[RefCategoryID] = b.[CategoryID] 
					 AND d.[RefCategoryGroupID] = c.[CategoryGroupID] and e.adid = @AdID) AS CategoryGrpNm,
					 a.EntryEligible, a.AdType, a.AdDistribution
					 ,CONCAT(a.ClassifiedBy ,SPACE(1), a.[ClassifiedDT]) AS ClassifiedBy
				FROM Ad a WHERE a.[AdID]=@AdID

					SELECT  Descrip As CoopPartners FROM [Advertiser] WHERE [AdvertiserID] IN (SELECT AdCoopComp.[AdvertiserID] FROM AdCoopComp
					WHERE [AdCoopID] = @AdID AND CoopCompCode = 'C')				

					SELECT  Descrip As Competitor FROM [Advertiser] WHERE [AdvertiserID] IN (SELECT AdCoopComp.[AdvertiserID] FROM AdCoopComp
					WHERE [AdCoopID] = @AdID AND CoopCompCode = 'X') 

					SELECT Descrip as CoopPartner_Combo FROM [Advertiser] WHERE [AdvertiserID] NOT IN 
					(SELECT AdCoopComp.[AdvertiserID] FROM AdCoopComp
					WHERE [AdCoopID] = @AdID AND CoopCompCode = 'C')

					--SELECT Advertiser as Competitor_Combo FROM Advertiser,AdCoopComp
					--WHERE PK_AdvertiserID = AdCoopComp.FK_AdvertiserID and AdCoopComp.CoopCompCode = 'X' and Advertiser NOT IN (SELECT  Advertiser As Competitor FROM Advertiser WHERE PK_AdvertiserID IN (SELECT AdCoopComp.FK_AdvertiserID FROM AdCoopComp
					--WHERE FK_AdID = @AdID AND CoopCompCode = 'X'))

					SELECT Descrip as Competitor_Combo FROM [Advertiser] WHERE [AdvertiserID] NOT IN 
					(SELECT AdCoopComp.[AdvertiserID] FROM AdCoopComp
					WHERE [AdCoopID] = @AdID AND CoopCompCode = 'X')
				
			
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
		SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
		RAISERROR ('[sp_ClassificationAdData]: %d: %s',16,1,@error,@message,@lineNo);
		ROLLBACK TRANSACTION
	END CATCH

END