-- ===========================================================================================
-- Author                         :      Asit
-- Create date                    :      16/10/2015
-- Description                    :      This stored procedure is used for getting Key elements Filter data
-- Execution Process              :      [dbo].[sp_GetKeyElementFilterData]
-- Updated By                     :      
-- ============================================================================================


CREATE PROCEDURE [dbo].[sp_GetKeyElementFilterData] 
AS 

  BEGIN 

      BEGIN TRY 

	  SELECT TOP 200 AdvertiserID,Descrip FROM [Advertiser] UNION SELECT 0 AS CategoryID,'Test' AS CategoryName ORDER BY AdvertiserID 
	  SELECT [RefCategoryID] As CategoryID,CategoryName FROM RefCategory UNION SELECT 0 AS CategoryID,'Test' AS CategoryName
	  SELECT ConfigurationID,Value FROM [Configuration] where systemname='All' and componentname='Media Stream'  UNION SELECT 0 AS CategoryID,'Test' AS CategoryName
	  --SELECT [MarketID],[Descrip] FROM [Market]
	  select RefTargetMarketID, Name from RefTargetMarket
	  SELECT [RefIndustryGroupID] AS IndustryGroupID,IndustryName FROM RefIndustryGroup UNION SELECT 0 AS IndustryGroupID,'Test' AS IndustryName
	  SELECT top 200 [RefSubCategoryID] AS SubCategoryID,SubCategoryName FROM RefSubCategory UNION SELECT 0 AS SubCategoryID,'Test' AS SubCategoryName
	  SELECT top 200 [RefProductID] AS ProductID,ProductName FROM RefProduct
      END TRY 

      BEGIN CATCH 

          DECLARE @error   INT,
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('sp_GetKeyElementFilterData: %d: %s',16,1,@error,@message,@lineNo); 

          ROLLBACK TRANSACTION 

      END catch; 

  END;