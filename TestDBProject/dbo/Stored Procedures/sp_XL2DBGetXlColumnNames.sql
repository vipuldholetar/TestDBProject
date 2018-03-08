
-- =============================================  
-- Author:    Nagarjuna  
-- Create date: 2/10/2015  
-- Description:  Retreiving XL Column Names 
-- Query : exec [sp_XL2DBGetXlColumnNames]  
-- =============================================  
CREATE PROC [dbo].[sp_XL2DBGetXlColumnNames] 
AS 
  BEGIN 
      SET NOCOUNT ON 

      BEGIN TRY 
          SELECT * 
          FROM   [ExcelColumnName] 
      END try 

      BEGIN catch 
          DECLARE @Error   INT, 
                  @Message VARCHAR(4000), 
                  @LineNo  INT 

          SELECT @Error = Error_number(), 
                 @Message = Error_message(), 
                 @LineNo = Error_line() 

          RAISERROR ('sp_XL2DBGetXlColumnNames: %d: %s',16,1,@Error,@Message,@LineNo); 
      END CATCH; 
  END;
