
-- ============================================= 
-- Author:    Rupinderjit 
-- Create date: 12/22/2014 
-- Description:  Delete Job Steps
-- Query : exec usp_DeleteJobStep
-- ============================================= 
CREATE PROC [dbo].[usp_DeleteJobStep] @jobstepid varchar(50)
AS 
  BEGIN 
      

      BEGIN try 

	 -- Delete Job Step
	  
      Delete [JobStep] where [JobStepCODE]=@jobstepid

      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('usp_DeleteJobStep: %d: %s',16,1,@error,@message,@lineNo); 
      END catch; 
  END;
