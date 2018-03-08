﻿
-- =============================================     
-- Author:    Nagarjuna     
-- Create date: 04/16/2015     
-- Description:  RCS Auto Indexing main procedure     
-- Query : exec sp_NLSIngestionSYNComNWFile  
-- =============================================    
CREATE PROCEDURE [dbo].[sp_NLSIngestionSYNComNWFile] (@NLSCSRFRawData dbo.NLSCSRFRawData readonly)
AS 
  BEGIN 
      SET nocount ON; 
      BEGIN try 
	  BEGIN TRANSACTION 
		
		EXEC [sp_NLSInsertSYNComNWRawData]  @NLSCSRFRawData                           
		EXEC [sp_NLSInsertSYNComNWFile]

	  COMMIT TRANSACTION 
	  END try 
      BEGIN catch 
          DECLARE @Error   INT, 
                  @Message VARCHAR(4000), 
                  @LineNo  INT 

          SELECT @Error = Error_number(), 
                 @Message = Error_message(), 
                 @LineNo = Error_line() 

          RAISERROR ('sp_NLSIngestionSYNComNWFile: %d: %s',16,1,@Error,@Message,@LineNo); 
		  ROLLBACK TRANSACTION 
      END catch; 
  END;
