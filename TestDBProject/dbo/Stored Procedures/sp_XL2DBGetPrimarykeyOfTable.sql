
-- =============================================  
-- Author:    Nagarjuna  
-- Create date: 2/11/2015  
-- Description:  Retreiving Primarykey column of a table 
-- Query : exec [sp_XL2DBGetPrimarykeyOfTable] 'TMSFileLogs'  
-- =============================================  
CREATE PROC [dbo].[sp_XL2DBGetPrimarykeyOfTable] (@TableName AS VARCHAR(50)) 
AS 
  BEGIN 
      SET NOCOUNT ON 

      BEGIN TRY 
          SELECT Col.Column_Name 
          FROM   information_schema.table_constraints Tab, 
                 information_schema.constraint_column_usage Col 
          WHERE  Col.Constraint_Name = Tab.Constraint_Name 
                 AND Col.Table_Name = Tab.Table_Name 
                 AND Constraint_Type = 'PRIMARY KEY' 
                 AND Col.Table_Name = @TableName 
      END TRY 

      BEGIN CATCH 
          DECLARE @Error   INT, 
                  @Message VARCHAR(4000), 
                  @LineNo  INT 

          SELECT @Error = Error_number(), 
                 @Message = Error_message(), 
                 @LineNo = Error_line() 

          RAISERROR ('sp_XL2DBGetPrimarykeyOfTable: %d: %s',16,1,@Error, 
                     @Message 
                     , 
                     @LineNo); 
      END CATCH; 
  END;
