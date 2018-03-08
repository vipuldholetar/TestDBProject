
-- ============================================= 
-- Author:    Rupinderjit 
-- Create date: 12/22/2014 
-- Description:  Update Job's Configuration
-- Query : exec usp_UpdateJobConfiguration
-- ============================================= 
CREATE PROC [dbo].[usp_UpdateJobConfiguration] @jobid varchar(20),@configuration nvarchar(max)
AS 
  BEGIN 
      SET nocount ON 

      BEGIN try 

	 -- Update Job Configuration

      Update [Job] set [Configuration]=@configuration where [JobCODE]=@jobid

      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('usp_UpdateJobConfiguration: %d: %s',16,1,@error,@message,@lineNo); 
      END catch; 
  END;
