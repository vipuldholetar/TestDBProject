-- ===========================================================================================
-- Author                         :      Asit
-- Create date                    :      7/10/2015
-- Description                    :      This stored procedure is used for getting Product data
-- Execution Process              :      [dbo].[sp_GetCategorySubCategory] 8
-- Updated By                     :      
-- ============================================================================================


CREATE PROCEDURE [dbo].[sp_GetCategorySubCategory] 
@ProductID varchar(10)
AS 

  BEGIN 

      BEGIN TRY 

		SELECT RSC.SubCategoryName, RC.CategoryName,RC.[KETemplateID] FROM RefSubCategory RSC INNER JOIN RefCategory RC ON RSC.[CategoryID]=RC.[RefCategoryID]
		INNER JOIN RefProduct RP ON RSC.[RefSubCategoryID]= RP.[SubCategoryID]
		WHERE RP.[RefProductID]=@ProductID

      END TRY 

      BEGIN CATCH 

          DECLARE @error   INT,
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('[sp_GetCategorySubCategory]: %d: %s',16,1,@error,@message,@lineNo); 

          ROLLBACK TRANSACTION 

      END catch; 

  END;
