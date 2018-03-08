
--=============================================  
-- Author:    Nanjunda  
-- Create date: 11/14/2014  
-- Description:  Loads the Data from flat file to TMS Translation table  
-- Query :  
/* 
  exec sp_XL2DBGetTableDetails 'TMSFileLogs'  
*/ 
-- =============================================  
CREATE PROCEDURE [dbo].[sp_XL2DBGetTableDetails] (@TableName AS NVARCHAR(50)) 
AS 
  BEGIN 
      SET NOCOUNT ON; 

      BEGIN TRY 
          BEGIN TRANSACTION 

          DECLARE @Command NVARCHAR(max) 

          -- set @Command='select name from sysobjects where  xtype=''u'' and name ='''+@TableName+'''' 
          SET @Command='exec sp_columns ' + @TableName 

          EXECUTE Sp_executesql @Command 

          COMMIT TRANSACTION 
      END TRY 

      BEGIN CATCH 
          DECLARE @Error   INT, 
                  @Message VARCHAR(4000), 
                  @LineNo  INT 

          SELECT @Error = Error_number(), 
                 @Message = Error_message(), 
                 @LineNo = Error_line() 

          RAISERROR ('sp_XL2DBGetTableDetails: %d: %s',16,1,@Error,@Message,@LineNo); 

          ROLLBACK TRANSACTION 
      END CATCH; 
  END
