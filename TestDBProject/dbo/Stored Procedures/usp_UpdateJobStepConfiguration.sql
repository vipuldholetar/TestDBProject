
-- ============================================= 
-- Author:    Rupinderjit 
-- Create date: 12/22/2014 
-- Description:  Update Job Step Configuration
-- Query : exec usp_UpdateJobStepConfiguration
-- ============================================= 
CREATE PROC [dbo].[usp_UpdateJobStepConfiguration] @jobstepid varchar(20),@configuration nvarchar(max)
AS 
  BEGIN 
      SET nocount ON 

      BEGIN try 

	 -- Update Job Configuration

      Update [JobStep] set [Configuration]=@configuration where [JobStepCODE]=@jobstepid

      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('usp_UpdateJobStepConfiguration: %d: %s',16,1,@error,@message,@lineNo); 
      END catch; 
  END;
