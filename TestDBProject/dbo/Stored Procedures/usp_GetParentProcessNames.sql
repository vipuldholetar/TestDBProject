

-- ============================================= 
-- Author:    Jayaprakash 
-- Create date: 01/05/2015 
-- Description:  Retreiving Process Names which has child processes
-- Query : exec [usp_GetParentProcessNames]
-- ============================================= 
CREATE PROC [dbo].[usp_GetParentProcessNames]
AS 
  BEGIN 
      SET nocount ON 

      BEGIN try 

          SELECT 
					[ProcessCODE],
					[ProcessCODE]+' - '+[Name] as ProcessNames,
					[Name],
					[ParentProcessID] as ParentID,
					[Type],
					[ProcessGroup] as ProcessGroup
          FROM   
					[dbo].[ProcessInventory]
		  WHERE
					[Status]='Active'
					And
					[ProcessCODE] in 
					(
						select 
								distinct [ParentProcessID] 
								
						from 
								[ProcessInventory]
						where 
								[ParentProcessID] is not null
					)
		  Order by
					[Name]
      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('usp_GetProcessNames: %d: %s',16,1,@error,@message,@lineNo); 
      END catch; 
  END;
