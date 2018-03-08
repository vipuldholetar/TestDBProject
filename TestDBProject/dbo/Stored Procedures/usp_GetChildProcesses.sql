
-- ============================================= 
-- Author:    Rupinderjit 
-- Create date: 12/18/2014 
-- Description:  Retreiving Child Processes
-- Query : exec usp_GetChildProcesses 
-- ============================================= 
CREATE PROC [dbo].[usp_GetChildProcesses] @processCODE varchar(20)
AS 
  BEGIN 
      SET nocount ON 

      BEGIN try 

		-- Get Child Processes 
      SELECT [ProcessInventoryID]
      ,[ProcessCODE]
      ,[Name]
      ,[Descrip]
      ,[Type]
      ,[Status]
      ,[ParentProcessID]
	  ,[ProcessGroup]
  FROM [dbo].[ProcessInventory] where [ParentProcessID]=@processCODE
          

      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('usp_GetChildProcesses: %d: %s',16,1,@error,@message,@lineNo); 
      END catch; 
  END;