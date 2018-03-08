

-- ============================================= 
-- Author:    Rupinderjit 
-- Create date: 12/18/2014 
-- Description:  Retreiving Process Names
-- Query : exec usp_GetProcessNames
-- ============================================= 
CREATE PROC [dbo].[usp_GetProcessNames]
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
					[ProcessGroup] as ProcessGroup
		  INTO
					#ProcessInventory
          FROM   
					[dbo].[ProcessInventory]
		
		  Order by
					[Name];

		  WITH    q AS
			(
				SELECT  [ProcessCODE],ProcessNames,[Name],[Descrip],ParentID,[Type],[Status],ProcessGroup
				FROM    #ProcessInventory
				UNION ALL
				SELECT  p.[ProcessCODE],p.ProcessNames,p.[Name],p.[Descrip],p.ParentID,p.[Type],p.[Status],p.ProcessGroup
				FROM    q
				JOIN    #ProcessInventory p
				ON      q.ProcessCODE = p.ParentID
			)

		SELECT  [ProcessCODE],ProcessNames,[Name],[Descrip],ParentID,[Type],[Status], COUNT(*)-1 as [ParentCount],ProcessGroup
		FROM    q
		GROUP BY
				[ProcessCODE],[ProcessCODE],ProcessNames,[Name],[Descrip],ParentID,[Type],[Status],ProcessGroup
		ORDER BY [Name] ASC
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