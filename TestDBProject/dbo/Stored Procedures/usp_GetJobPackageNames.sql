
-- ============================================= 
-- Author:    Rupinderjit 
-- Create date: 12/18/2014 
-- Description:  Retreiving Job Package Names 
-- Query : exec usp_GetJobPackageNames
-- ============================================= 
CREATE PROC [dbo].[usp_GetJobPackageNames] 
AS 
  BEGIN 
      SET nocount ON 

      BEGIN try 

		-- Get Job Details
         SELECT [ProcessCODE],[JobCODE],[JobPackageCODE]+' - '+[Name] as JobPackageNames,[JobPackageCODE]
                
          FROM   [dbo].[JobPackage] 
          

      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('usp_GetJobPackageNames: %d: %s',16,1,@error,@message,@lineNo); 
      END catch; 
  END;
