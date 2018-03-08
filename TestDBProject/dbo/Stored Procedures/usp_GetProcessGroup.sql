-- ============================================= 
-- Author:    Murali 
-- Create date: 02/16/2015 
-- Description:  Retreiving Process Group
-- Query : exec usp_GetProcessGroup
-- ============================================= 
CREATE PROC [dbo].[usp_GetProcessGroup]
AS 
  BEGIN 
      SET nocount ON 

      BEGIN try 

          SELECT distinct
					[ProcessGroup] as Processgroup
          FROM   
					[dbo].[ProcessInventory]
		  WHERE [ProcessGroup] is not null
		  Order by
					1;
      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('usp_GetProcessGroup: %d: %s',16,1,@error,@message,@lineNo); 
      END catch; 
  END;
