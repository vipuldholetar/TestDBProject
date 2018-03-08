
-- ============================================= 
-- Author:    Rupinderjit 
-- Create date: 12/18/2014 
-- Description:  Retreiving Job Names related to a process 
-- Query : exec usp_GetJobNames
-- ============================================= 
CREATE PROC [dbo].[usp_GetJobNames]
AS 
  BEGIN 
      SET nocount ON 

      BEGIN try 

		-- Get Job Details
         SELECT [JobCODE],[JobCODE]+' - '+[Name] as JobNames,[ProcessCODE]
                
          FROM   [dbo].[Job] 
          

      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('usp_GetJobNames: %d: %s',16,1,@error,@message,@lineNo); 
      END catch; 
  END;