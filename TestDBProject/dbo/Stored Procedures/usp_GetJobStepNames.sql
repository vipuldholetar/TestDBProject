
-- ============================================= 
-- Author:    Rupinderjit 
-- Create date: 12/21/2014 
-- Description:  Retreiving Job step Names
-- Query : exec usp_GetJobStepNames
-- ============================================= 
CREATE PROC [dbo].[usp_GetJobStepNames] 
AS 
  BEGIN 
      SET nocount ON 

      BEGIN try 

		-- Get Job Step Names
       SELECT  [ProcessCODE],[JobCODE],[JobPackageCODE],[JobStepCODE],[JobStepCODE] +' - '+[Name] as JobStepNames from [dbo].[JobStep]

      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('usp_GetSpecifiJobStep: %d: %s',16,1,@error,@message,@lineNo); 
      END catch; 
  END;
