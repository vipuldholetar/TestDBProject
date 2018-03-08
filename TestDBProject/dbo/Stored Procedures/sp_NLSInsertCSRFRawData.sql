
-- ============================================= 
-- Author:    Nagarjuna 
-- Create date: 06/02/2015 
-- Description:  Delete Job Steps
-- Query : exec sp_NLSInsertCSRFRawData
-- ============================================= 
CREATE PROC [dbo].[sp_NLSInsertCSRFRawData] (@NLSCSRFRawData dbo.NLSCSRFRawData readonly) 
AS 
  BEGIN       

      BEGIN try 

	   BEGIN TRANSACTION 
	   truncate table [NLSNCSRFRawData]

	 INSERT INTO [dbo].[NLSNCSRFRawData] 
                      (NLSRawData) 
          SELECT NLSRawData
          FROM   @NLSCSRFRawData 	
    COMMIT TRANSACTION 
	
      END try 

      BEGIN catch 
          DECLARE @Error   INT, 
                  @Message VARCHAR(4000), 
                  @LineNo  INT 

          SELECT @Error = Error_number(), 
                 @Message = Error_message(), 
                 @LineNo = Error_line() 

          RAISERROR ('sp_NLSInsertCSRFRawData: %d: %s',16,1,@Error,@Message,@LineNo); 
		  ROLLBACK TRANSACTION 
      END catch; 
  END;
