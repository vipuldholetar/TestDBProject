
--=============================================  
-- Author:    Nanjunda  
-- Create date: 11/14/2014  
-- Description:  Loads the Data from flat file to TMS Translation table  
-- Query :  
/* 
  exec sp_XL2DBExcecuteCommand 'INSERT INTO TMS_FILE_LOGS ( FileName , FileRecordCount,AirDate,TranslationImportCount )  VALUES ( ''abc.txt'' , ''10'',''2015-02-03 07:54:04.160'',''10'' )'  
*/ 
-- =============================================  
CREATE PROCEDURE [dbo].[sp_XL2DBExcecuteCommand] (@Command AS NVARCHAR(max)) 
AS 
  BEGIN 
      SET NOCOUNT OFF; 

      BEGIN TRY 
          DECLARE @RowCount INT 

          BEGIN TRANSACTION 

          EXECUTE Sp_executesql 
            @Command 

          SELECT @@RowCount 

          COMMIT TRANSACTION 
      END TRY 

      BEGIN CATCH 
          DECLARE @Error   INT, 
                  @Message VARCHAR(4000), 
                  @LineNo  INT 

          SELECT @Error = Error_number(), 
                 @Message = Error_message(), 
                 @LineNo = Error_line() 

          RAISERROR ('sp_XL2DBExcecuteCommand: %d: %s',16,1,@Error,@Message, 
                     @LineNo) 
          ; 

          ROLLBACK TRANSACTION 
      END CATCH; 
  END
