
-- ============================================= 
-- Author:    Jayaprakash 
-- Create date: 01/07/2015 
-- Description:  To inactivate the MSMQ IP address, if deleted from UI
-- Query : exec [usp_DeleteMSMQServerIP] '182.198.1.1' 
-- ============================================= 
CREATE PROC [dbo].[usp_DeleteMSMQServerIP] @ServerIP varchar(100)
AS 
  BEGIN 
      SET nocount ON 

      BEGIN try 

	  UPDATE [MSMQServer]
	  Set Status=0
	  Where [ServerIP]=@ServerIP

      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('usp_DeleteMSMQServerIP: %d: %s',16,1,@error,@message,@lineNo); 
      END catch; 
  END;
