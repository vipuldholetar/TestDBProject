
-- ============================================= 
-- Author:    Rupinderjit 
-- Create date: 12/22/2014 
-- Description:  Delete Job
-- Query : exec usp_DeleteJob
-- ============================================= 
CREATE PROC [dbo].[usp_DeleteJob] @jobid varchar(50)
AS 
  BEGIN 
      

      BEGIN try 

	 -- Delete Job
	  
      Delete [Job] where [JobCODE]=@jobid

      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('usp_DeleteJob: %d: %s',16,1,@error,@message,@lineNo); 
      END catch; 
  END;
