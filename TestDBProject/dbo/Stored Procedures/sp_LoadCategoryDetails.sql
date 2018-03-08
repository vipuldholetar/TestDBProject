-- ===========================================================================
-- Author			:Govardhan
-- Create date		:12 Aug 2015
-- Description		:Get  category detail Values
--=============================================================================
CREATE PROCEDURE [dbo].[sp_LoadCategoryDetails]
AS
BEGIN
SET NOCOUNT ON;
		BEGIN TRY
		    SELECT * FROM (
		    SELECT 0[ID],'---Select---'[SubCategoryName]
			UNION
			SELECT DISTINCT RSC.[RefSubCategoryID][ID],RSC.SubCategoryName
			FROM AD A,REFPRODUCT RP , REFSUBCATEGORY RSC
			WHERE RP.[SubCategoryID]=RSC.[RefSubCategoryID] AND A.ProductId=RP.[RefProductID] 
			)SUB order by SubCategoryName asc

			SELECT * FROM (
			SELECT 0[ID],'---Select---'[CategoryName]
			UNION
			SELECT DISTINCT	RC.[RefCategoryID][ID],RC.CategoryName
			FROM Ad A, RefProduct RP, RefSubCategory RSC, RefCategory RC
			WHERE 
			A.ProductId=RP.[RefProductID] AND RP.[SubCategoryID]=RSC.[RefSubCategoryID] AND RSC.[CategoryID]=RC.[RefCategoryID] 
			) SUB order by CategoryName asc
		END TRY
		BEGIN CATCH 
			  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
			  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			  RAISERROR ('[sp_LoadCategoryDetails]: %d: %s',16,1,@error,@message,@lineNo); 			  
		END CATCH 
END
