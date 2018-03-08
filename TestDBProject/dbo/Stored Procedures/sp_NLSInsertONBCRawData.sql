
-- ============================================= 
-- Author:    Nagarjuna 
-- Create date: 06/02/2015 
-- Description:  This procedure is used to load Overnight broadcast file to NLSONBroadCastRawData table
-- Query : exec sp_NLSInsertONBBCRawData
--drop procedure sp_NLSInsertONBBCRawData
-- ============================================= 
CREATE PROC [dbo].[sp_NLSInsertONBCRawData] (@NLSRawData dbo.NLSRawData readonly) 
AS 
  BEGIN       

      BEGIN try 

	   BEGIN TRANSACTION 

	   Truncate table [NLSNBCRawData]

	 INSERT INTO [dbo].[NLSNBCRawData] 
                      (NLSRawData) 
          SELECT NLSRawData
          FROM   @NLSRawData 	
    COMMIT TRANSACTION 
	
      END try 

      BEGIN catch 
          DECLARE @Error   INT, 
                  @Message VARCHAR(4000), 
                  @LineNo  INT 

          SELECT @Error = Error_number(), 
                 @Message = Error_message(), 
                 @LineNo = Error_line() 

          RAISERROR ('sp_NLSInsertONBBCRawData: %d: %s',16,1,@Error,@Message,@LineNo); 
      END catch; 
  END;
