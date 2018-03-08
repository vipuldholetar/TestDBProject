
--=============================================  
-- Author:    Nanjunda  
-- Create date: 11/14/2014  
-- Description:  Loads the Data from flat file to TMS Translation table  
-- Query :  
/* 
  exec usp_XL2DB_ExcecuteCommand 'INSERT INTO TMS_FILE_LOGS ( FileName , FileRecordCount,AirDate,TranslationImportCount )  VALUES ( ''abc.txt'' , ''10'',''2015-02-03 07:54:04.160'',''10'' )'  
*/ 
-- =============================================  
CREATE PROCEDURE [dbo].[usp_XL2DB_ExcecuteCommand] (@Command AS NVARCHAR(max)) 
AS 
  BEGIN 
      SET NOCOUNT OFF; 

      BEGIN TRY 
          DECLARE @rowcount INT 

          BEGIN TRANSACTION 

          EXECUTE Sp_executesql 
            @Command 

          SELECT @@ROWCOUNT 

          COMMIT TRANSACTION 
      END TRY 

      BEGIN CATCH 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('usp_XL2DB_ExcecuteCommand: %d: %s',16,1,@error,@message, 
                     @lineNo) 
          ; 

          ROLLBACK TRANSACTION 
      END CATCH; 
  END
