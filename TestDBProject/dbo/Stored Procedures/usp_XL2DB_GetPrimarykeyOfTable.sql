
-- =============================================  
-- Author:    Nagarjuna  
-- Create date: 2/11/2015  
-- Description:  Retreiving Primarykey column of a table 
-- Query : exec [usp_XL2DB_GetPrimarykeyOfTable] 'TMS_FILE_LOGS'  
-- =============================================  
CREATE PROC [dbo].[usp_XL2DB_GetPrimarykeyOfTable] (@TableName AS VARCHAR(50)) 
AS 
  BEGIN 
      SET NOCOUNT ON 

      BEGIN TRY 
          SELECT Col.column_name 
          FROM   information_schema.table_constraints Tab, 
                 information_schema.constraint_column_usage Col 
          WHERE  Col.constraint_name = Tab.constraint_name 
                 AND Col.table_name = Tab.table_name 
                 AND constraint_type = 'PRIMARY KEY' 
                 AND Col.table_name = @TableName 
      END TRY 

      BEGIN CATCH 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('usp_XL2DB_GetPrimarykeyOfTable: %d: %s',16,1,@error, 
                     @message 
                     , 
                     @lineNo); 
      END CATCH; 
  END;
