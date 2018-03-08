-- =============================================    
-- Author:    Govardhan    
--Create date: 06/22/2015    
-- Description: Ingest data to the raw data table.   
-- Query :    
/*   

exec sp_NLSInsertIngRawData ,'0'

*/ 
-- =============================================    
CREATE PROCEDURE [dbo].[sp_NLSInsertIngRawData] (@NIELSONINGNWData 
dbo.NIELSONINGNWDATA readonly, 
                                                 @Truncate         INT) 
AS 
  BEGIN 
      SET nocount ON; 

      DECLARE @RecordsCnt AS INT; 

      BEGIN try 
         -- BEGIN TRANSACTION 

          --IF(@Truncate=1) 
          --BEGIN 
          --TRUNCATE TABLE NLSIngRawData 
          --END 
          SELECT @RecordsCnt = Count(*) 
          FROM   [NLSNIngRawData] 

          INSERT INTO [NLSNIngRawData] 
                      ([NLSNIngRawDataID], 
                       value) 
          SELECT Newid(), 
                 value 
          FROM   @NIELSONINGNWData 

          SELECT ( Count(*) - @RecordsCnt )[ImportedRecCount] 
          FROM   [NLSNIngRawData] 

         -- COMMIT TRANSACTION 
      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('sp_NLSInsertIngRawData: %d: %s',16,1,@error,@message, 
                     @lineNo 
          ); 

          --ROLLBACK TRANSACTION 
      END catch; 
  END;
