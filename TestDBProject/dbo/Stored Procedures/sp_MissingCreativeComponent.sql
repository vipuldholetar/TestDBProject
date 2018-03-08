

-- ====================================================================================
-- Author                         :      Ganesh Prasad
-- Create date                    :      09/07/2015
-- Description                    :      This stored procedure is used to Get Data for "Missing Creative Component" SSRS Report
-- Execution Process              :     [dbo].[sp_MissingCreativeComponent]
-- Updated By                     :     

-- ====================================================================================
CREATE Procedure [dbo].[sp_MissingCreativeComponent]
AS
BEGIN
SET NOCOUNT ON;
BEGIN TRY
select
       [dbo].Ad.[AdID] as AdId, 
       [dbo].[Configuration].ValueTitle as  MediaType, 
       convert(Date,[dbo].Ad.FirstRunDate) as FirstRunDate,
	   convert(Date,[dbo].Ad.LastRunDate) as LastRunDate,
       convert(Date,[dbo].Ad.CreateDate) as CreateDate,
       [dbo].REFCategory.CategoryName as Category,
       '' as BadTapeIndicator, ----No DB Column Specified
       '' as  DeleteFlag,      ----No DB Column Specified
       '' as Description       ----No DB Column Specified
         from [dbo].[Pattern]
      Inner join  [dbo].[Configuration] 
	  on [dbo].[Pattern].MediaStream=[dbo].[Configuration].ConfigurationID
      Inner Join [dbo].Ad
      On [dbo].[Pattern].[AdID] = [dbo].Ad.[AdID]
      Inner Join [dbo].RefProduct 
      On [dbo].Ad.ProductId = [dbo].RefProduct.[RefProductID]
      Inner Join [dbo].RefSubCategory
      On [dbo].RefProduct.[SubCategoryID] = [dbo].RefSubCategory.[RefSubCategoryID]
      Inner Join [dbo].RefCategory
      On [dbo].RefSubCategory.[CategoryID] = [dbo].RefCategory.[RefCategoryID]
	  where [CreativeID] is null
END TRY
				
		   BEGIN CATCH 
             DECLARE @error  INT, @message VARCHAR(4000),@lineNo  INT 
             SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
             RAISERROR ('[sp_MissingCreativeComponent]: %d: %s',16,1,@error,@message,@lineNo); 
           END CATCH 

	END
