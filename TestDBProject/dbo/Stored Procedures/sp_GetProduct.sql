-- ===========================================================================================
-- Author                         :      Asit
-- Create date                    :      29/09/2015
-- Description                    :      This stored procedure is used for getting Product data
-- Execution Process              :      [dbo].[sp_GetProduct]
-- Updated By                     :      
-- ============================================================================================


CREATE PROCEDURE [dbo].[sp_GetProduct] 

AS 

  BEGIN 

      BEGIN TRY 

		SELECT ref.[RefProductID],ProductName
		FROM RefProduct ref INNER JOIN Ad
		ON ref.[CTLegacyPRCODE] = Ad.ProductID

      END TRY 

      BEGIN CATCH 

          DECLARE @error   INT,
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('sp_GetProduct: %d: %s',16,1,@error,@message,@lineNo); 

          ROLLBACK TRANSACTION 

      END catch; 

  END;
