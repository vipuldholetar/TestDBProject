
-- ============================================= 
-- Author:    Rupinderjit 
-- Create date: 12/18/2014 
-- Description:  Retreiving Active Process Names
-- Query : exec usp_GetActiveProcessNames
-- Comments : Jayaprakash - 5-Jan-2014 - Added active condition and added Parent ID and type as part of the output
-- ============================================= 
CREATE PROC [dbo].[usp_GetActiveProcessNames]
AS 
  BEGIN 
      SET nocount ON 

      BEGIN try 

          SELECT 
					[ProcessCODE],
					[ProcessCODE]+' - '+[Name] as ProcessNames,
					[Name],
					[Descrip],
					[ParentProcessID] as ParentID,
					[Type],
					[Status],
					[ProcessGroup]
		  INTO
					#ProcessInventory
          FROM   
					[dbo].[ProcessInventory]
		  WHERE
					[Status]='Active'
		  Order by
					[Name];
		  
		
		  WITH    q AS
			(
				SELECT  [ProcessCODE],ProcessNames,[Name],[Descrip],ParentID,[Type],[Status],[ProcessGroup]
				FROM    #ProcessInventory
				UNION ALL
				SELECT  p.[ProcessCODE],p.ProcessNames,p.[Name],p.[Descrip],p.ParentID,p.[Type],p.[Status],p.[ProcessGroup]
				FROM    q
				JOIN    #ProcessInventory p
				ON      q.ProcessCODE = p.ParentID
			)

		SELECT  [ProcessCODE],ProcessNames,[Name],[Descrip],ParentID,[Type],[Status], COUNT(*)-1 as [ParentCount],[ProcessGroup]
		FROM    q
		GROUP BY
				[ProcessCODE],[ProcessCODE],ProcessNames,[Name],[Descrip],ParentID,[Type],[Status],[ProcessGroup]
		
		DROP TABLE #ProcessInventory
      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('usp_GetActiveProcessNames: %d: %s',16,1,@error,@message,@lineNo); 
      END catch; 
  END;