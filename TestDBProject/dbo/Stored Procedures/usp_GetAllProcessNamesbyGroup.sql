-- ============================================= 
-- Author:    Murali Jaganathan
-- Create date: 02/16/2015 
-- Description:  Retreiving Process Names by Group
-- Query : exec [usp_GetAllProcessNamesbyGroup] 'Spend Methodology'
--		   exec [usp_GetAllProcessNamesbyGroup] 'Ingestion'
-- ============================================= 

CREATE PROC [dbo].[usp_GetAllProcessNamesbyGroup] @processgroup varchar(50)

AS 
  BEGIN 
      SET nocount ON 
      BEGIN try 
	  BEGIN
		-- Get All Active Process Names by Process Group Names
	  SELECT 		  
		  [Name] as ProcessName,
		  [ProcessCODE] 
          FROM   [dbo].[ProcessInventory]
		  WHERE [ProcessGroup] = @processgroup
		  And [Status] = 'Active'          
      END
	  END try 
      BEGIN catch 

          DECLARE @error   INT, 
                  @message VARCHAR(4000),
                  @lineNo  INT 

          SELECT @error = Error_number(),
                 @message = Error_message(),
                 @lineNo = Error_line() 

          RAISERROR ('usp_GetAllJobs: %d: %s',16,1,@error,@message,@lineNo);
      END catch;
  END;
