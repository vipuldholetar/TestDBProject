-- ===========================================================================================
-- Author                         :      Ganesh prasad
-- Create date                    :      09/08/2015
-- Description                    :      This stored procedure is used for getting Data to "DailyAdAlert" Report Dataset
-- Execution Process              :      [dbo].[sp_DailyAdAlert]
-- Updated By                     :      
-- ============================================================================================

CREATE PROCEDURE [dbo].[sp_DailyAdAlert]
 AS
BEGIN
SET NOCOUNT ON;
BEGIN TRY
	select distinct [dbo].Ad.[AdID] as AdId,
	                [dbo].[Configuration].ValueTitle as  MediaType, 
                   [dbo].[Advertiser].Descrip as AdvertiserName,
                   [dbo].[Language].[Description] as Language,
		            '' as [Headline/LeadAudio],----- No DB column Specified
           [dbo].Ad.AdLength as [AdLength/Size],
           [dbo].Ad.FirstRunDate  as FirstRunDate,
            '' as [New/Recut],----- No DB column Specified
           [dbo].Ad.[OriginalAdID] as OriginalAdId,
		   '' as  [Station/Publication],
		   '' as Market,--Marketmaster.Description as Market,----------------Need Clarification on this column
           --[dbo].RefSubCategory.SubCategoryName as SubCategory,
           --[dbo].RefProduct.ProductName as Product,
           --[dbo].RefCategory.CategoryName as Category,
		    '' as SubCategory,
          '' as Product,
           '' as Category,
            '' as QualityCode, ----- No DB column Specified
           [dbo].Ad.Createdate as CreateDate,
           [dbo].[User].fname+' '+[dbo].[user].lname as [Created By],
            '' as ClientAlert ----- No DB column Specified
           from [dbo].Ad
        Inner Join [dbo].[Pattern]
        on [dbo].[Pattern].[AdID] = [dbo].Ad.[AdID]
       --Inner Join MarketMaster
       --On Ad.FK_MarketID = MarketMaster.MarketCode -----Need clarification on this Join 
        --Inner Join [dbo].RefProduct
        --on [dbo].Ad.ProductId = [dbo].RefProduct.PK_Id
       Inner Join [dbo].[Language] -- To be replaced with reflanguage
       on [dbo].Ad.[LanguageID] = [dbo].[Language].LanguageID
       Inner Join [dbo].[Advertiser] 
       On [dbo].Ad.[AdvertiserID] = [dbo].[Advertiser].AdvertiserID
       Inner Join [dbo].[User]
       On  [dbo].Ad.CreatedBy = [dbo].[User].UserId
       Inner join  [dbo].[Configuration] 
       on  [dbo].[Pattern].MediaStream= [dbo].[Configuration].ConfigurationID
       --Inner Join RefSubCategory
       --on [dbo].RefProduct.FK_SubCategoryId = [dbo].RefSubCategory.PK_ID
       --Inner Join RefCategory
       --On [dbo].RefSubCategory.FK_CategoryId = [dbo].RefCategory.PK_Id
    
	END TRY

				 BEGIN CATCH 

                DECLARE @error   INT, @message VARCHAR(4000), @lineNo  INT 
                SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			    RAISERROR ('[sp_DailyAdAlert]: %d: %s',16,1,@error,@message,@lineNo); 

                END CATCH 
END
