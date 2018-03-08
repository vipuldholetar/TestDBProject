
-- ============================================= 
-- Author:    Jayaprakash 
-- Create date: 01/05/2015
-- Description:  Get MSMQ Server IP details
-- Query : exec [usp_GetMSMQServerIPDetails]  
-- ============================================= 
CREATE PROC [dbo].[usp_GetMSMQServerIPDetails]
AS 
  BEGIN 
      SET nocount ON 

      BEGIN try 
          SELECT 
				 [ServerIP]
          FROM   
				 [dbo].[MSMQServer] 
		  WHERE
				 [Status]=1
      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('usp_RetreiveJob: %d: %s',16,1,@error,@message,@lineNo); 
      END catch; 
  END;
