
-- =============================================  
-- Author:    Nagarjuna  
-- Create date: 2/10/2015  
-- Description:  Retreiving XL Column Names 
-- Query : exec [usp_XL2DB_GetXLColumnNames]  
-- =============================================  
CREATE PROC [dbo].[usp_XL2DB_GetXLColumnNames] 
AS 
  BEGIN 
      SET NOCOUNT ON 

      BEGIN TRY 
          SELECT * 
          FROM   xl_column_names 
      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('Usp_xl2db_getxlcolumnnames: %d: %s',16,1,@error,@message,@lineNo); 
      END CATCH; 
  END;
