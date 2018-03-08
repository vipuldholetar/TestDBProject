
-- ============================================= 
-- Author:    Nagarjuna 
-- Create date: 06/02/2015 
-- Description:  Delete Job Steps
-- Query : exec sp_NLSInsertONCableRawData
--drop procedure sp_NLSInsertONCableRawData
-- ============================================= 
CREATE PROC [dbo].[sp_NLSInsertONCableRawData] (@NLSONBroadCastRaw dbo.NLSONBroadCastRaw readonly)
AS 
  BEGIN       

      BEGIN try 

	   BEGIN TRANSACTION 
	   truncate table [NLSNCableRawData]

	 INSERT INTO [dbo].[NLSNCableRawData] 
                      (NLSRawData) 
          SELECT NLSRawData
          FROM   @NLSONBroadCastRaw 	
    COMMIT TRANSACTION 
	
      END try 

      BEGIN catch 
          DECLARE @Error   INT, 
                  @Message VARCHAR(4000), 
                  @LineNo  INT 

          SELECT @Error = Error_number(), 
                 @Message = Error_message(), 
                 @LineNo = Error_line() 

          RAISERROR ('sp_NLSInsertONCableRawData: %d: %s',16,1,@Error,@Message,@LineNo); 
		  ROLLBACK TRANSACTION 
      END catch; 
  END;
