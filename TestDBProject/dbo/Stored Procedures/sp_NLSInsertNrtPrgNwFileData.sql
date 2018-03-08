-- =============================================   
-- Author:    Govardhan   
--Create date: 05/22/2015   
-- Description: Ingest data to the raw data table.  
-- Query :   
/*  
exec sp_NIELSONInsertNRTProgramNWFileData '',  
*/ 
-- =============================================   
CREATE PROCEDURE [dbo].[sp_NLSInsertNrtPrgNwFileData] (@NIELSONINGNWData dbo.NIELSONINGNWData 
readonly) 
AS 
  BEGIN 
        SET nocount ON; 

      BEGIN try 

          BEGIN TRANSACTION 

		  INSERT INTO [NLSNIngRawData]([NLSNIngRawDataID],Value)
		  SELECT NEWID(),VALUE 
		  FROM @NIELSONINGNWData

		  COMMIT TRANSACTION 

      END try 
      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 
          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 
          RAISERROR ('sp_NLSInsertNrtPrgNwFileData: %d: %s',16,1,@error,@message, 
                    @lineNo 
          ); 
          ROLLBACK TRANSACTION 
      END catch; 
  END;
