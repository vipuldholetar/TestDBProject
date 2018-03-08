-- ============================================= 
-- Author:    Nanjunda 
-- Create date: 12/18/2014 
-- Description:  Retreiving all Child Processes
-- Query : exec usp_GetAllChildProcesses 'SM01'
-- ============================================= 
CREATE PROC [dbo].[usp_GetAllChildProcesses] @processCODE nvarchar(20)
AS 
  BEGIN 
      SET NOCOUNT ON 

      BEGIN try 

		;WITH TempInventory AS
(
	SELECT DISTINCT  [ParentProcessID] ,[ParentProcessID] AS ProcessCODE,[Name],[Descrip],[Type],[Status],[ParentProcessID] ,1 as [Level]
	,[ProcessGroup] as Processgroup
	FROM [ProcessInventory] WHERE [ParentProcessID] =@processCODE
	UNION ALL
	SELECT C.ParentProcessID, S.[ProcessCODE] ,s.[Name],s.[Descrip],s.[Type],s.[Status],s.[ParentProcessID] ,level+1,s.[ProcessGroup] as Processgroup
	FROM [ProcessInventory] S INNER JOIN TempInventory C ON S.[ParentProcessID] = C.ProcessCODE
)

select distinct [ParentProcessID] as ParentID,[ParentProcessID] AS ProcessCODE,[Name],[Descrip],[Type],[Status],[ParentProcessID],Processgroup FROM TempInventory
 union all
 SELECT DISTINCT  [ParentProcessID] as ParentID,[ParentProcessID] AS ProcessCODE,[Name],[Descrip],[Type],[Status],[ParentProcessID],[ProcessGroup]  as Processgroup
	FROM [ProcessInventory] WHERE [ProcessCODE] =@processCODE         
order by ProcessCODE
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