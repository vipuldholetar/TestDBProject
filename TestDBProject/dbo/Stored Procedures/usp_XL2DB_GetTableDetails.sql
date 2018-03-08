
--=============================================  
-- Author:    Nanjunda  
-- Create date: 11/14/2014  
-- Description:  Loads the Data from flat file to TMS Translation table  
-- Query :  
/* 
  exec usp_XL2DB_GetTableDetails 'TMS_FILE_LOGS'  
*/ 
-- =============================================  
CREATE PROCEDURE [dbo].[usp_XL2DB_GetTableDetails] (@TableName AS NVARCHAR(50)) 
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
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('usp_XL2DB_GetTableDetails: %d: %s',16,1,@error,@message, 
                     @lineNo) 
          ; 

          ROLLBACK TRANSACTION 
      END CATCH; 
  END
