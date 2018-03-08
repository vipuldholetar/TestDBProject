-- ===========================================================================================
-- Author                         :      Asit
-- Create date                    :      29/09/2015
-- Description                    :      This stored procedure is used for getting Ad data
-- Execution Process              :      [dbo].[sp_GetTargetMarket]
-- Updated By                     :      
-- ============================================================================================


CREATE PROCEDURE [dbo].[sp_GetTargetMarket] 

AS 

  BEGIN 

      BEGIN TRY 

		SELECT [MarketID], [Descrip] FROM [Market]

      END TRY 

      BEGIN CATCH 

          DECLARE @error   INT,
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('sp_GetTargetMarket: %d: %s',16,1,@error,@message,@lineNo); 

          ROLLBACK TRANSACTION 

      END catch; 

  END;
