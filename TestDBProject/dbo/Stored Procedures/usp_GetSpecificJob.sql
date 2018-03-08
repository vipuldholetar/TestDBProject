-- =============================================   
-- Author:    Rupinderjit   
-- Create date: 12/18/2014   
-- Description:  Retreiving Job details   
-- Query : exec usp_GetSpecificJob 'JB01', 'true'  
-- =============================================   

--[usp_GetSpecificJob] 'JB01', 'false' 

CREATE PROC [dbo].[usp_GetSpecificJob] @jobid VARCHAR(20), @isOnlyActive VARCHAR(20) 
AS 
  BEGIN 
      SET nocount ON 

      BEGIN try
	  
	  IF( @isOnlyActive = 'false')
	  BEGIN	  

	  
          -- Get Job Details  
         SELECT j.id, 
                 j.[JobCODE], 
                 j.[ProcessCODE], 
                 j.[Name], 
                 j.[Descrip], 
                 j.[Status], 
                 j.[Type], 
                 j.[StartupType], 
                 j.[Configuration],
				 j.[CreateDT],
				 pi.[Name] as processname 
          FROM   dbo.[Job] j  inner join [ProcessInventory] pi on j.[ProcessCODE]=pi.[ProcessCODE] 
          WHERE  [JobCODE] = @jobid 

          -- Get Job package Details  
          SELECT jp.[JobPackageID], 
                 jp.[JobPackageCODE], 
                 jp.[ProcessCODE], 
                 jp.[JobCODE], 
                 jp.[Name], 
                 jp.[Descrip], 
                 jp.[Order], 
                 jp.[Predecessor], 
                 jp.[CreatedDT], 
                 jp.[Configuration],
				 jp.[Status], 
                 pi.parentprocessname AS source, 
                 pi.processname       AS target, 
                 jp.[Source]            AS sourceID, 
                 jp.[Target]            AS targetID 
          FROM   [dbo].[JobPackage] jp 
                 INNER JOIN (SELECT pi2.[ProcessCODE] AS process_id, 
                                    pi1.[ProcessCODE] AS parent_process_id, 
                                    pi2.[Name]       AS Processname, 
                                    pi1.[Name]       AS ParentProcessName 
                             FROM   [ProcessInventory] pi1 
                                    INNER JOIN [ProcessInventory] pi2 
                                            ON pi1.[ProcessCODE] = 
                                               pi2.[ParentProcessID]) 
                            pi 
                         ON jp.[Target] = pi.[Process_id] 
          WHERE  [JobCODE] = @jobid order by [Order]

          -- Get Job Step Details related to Job and Job package  
          SELECT js.[JobStepID], 
                 js.[JobStepCODE], 
                 js.[JobCODE], 
                 js.[JobPackageCODE], 
                 js.[ProcessCODE], 
                 js.[Name], 
                 js.[Descrip], 
                 js.[Order], 
                 js.[Predecessor], 
                 js.[CreatedDT], 
                 js.[Configuration], 
				 js.[Status],
                 pi.parentprocessname AS source, 
                 pi.processname       AS target, 
                 js.[Source]            AS sourceID, 
                 js.[Target]            AS targetID 
          FROM   [dbo].[JobStep] js 
                 INNER JOIN (SELECT pi2.[ProcessCODE] AS process_id, 
                                    pi1.[ProcessCODE] AS parent_process_id, 
                                    pi2.[Name]       AS Processname, 
                                    pi1.[Name]       AS ParentProcessName 
                             FROM   [ProcessInventory] pi1 
                                    INNER JOIN [ProcessInventory] pi2 
                                            ON pi1.[ProcessCODE] = 
                                               pi2.[ParentProcessID]) 
                            pi 
                         ON js.[Target] = pi.[Process_id] 
          WHERE  [JobCODE] = @jobid 
                 AND [JobPackageCODE] IS NOT NULL order by [Order]

		END
	  ELSE
	  BEGIN
	  SET @isOnlyActive = 'Active'
	    -- Get Job Details  
         SELECT j.id, 
                 j.[JobCODE], 
                 j.[ProcessCODE], 
                 j.[Name], 
                 j.[Descrip], 
                 j.[Status], 
                 j.[Type], 
                 j.[StartupType], 
                 j.[Configuration],
				 j.[CreateDT],
				 pi.[Name] as processname 
          FROM   dbo.[Job] j  inner join [ProcessInventory] pi on j.[ProcessCODE]=pi.[ProcessCODE] 
          WHERE  [JobCODE] = @jobid AND j.[Status] = @isOnlyActive

          -- Get Job package Details  
          SELECT jp.[JobPackageID], 
                 jp.[JobPackageCODE], 
                 jp.[ProcessCODE], 
                 jp.[JobCODE], 
                 jp.[Name], 
                 jp.[Descrip], 
                 jp.[Order], 
                 jp.[Predecessor], 
                 jp.[CreatedDT], 
                 jp.[Configuration],
				 jp.[Status], 
                 pi.parentprocessname AS source, 
                 pi.processname       AS target, 
                 jp.[Source]            AS sourceID, 
                 jp.[Target]            AS targetID 
          FROM   [dbo].[JobPackage] jp 
                 INNER JOIN (SELECT pi2.[ProcessCODE] AS process_id, 
                                    pi1.[ProcessCODE] AS parent_process_id, 
                                    pi2.[Name]       AS Processname, 
                                    pi1.[Name]       AS ParentProcessName 
                             FROM   [ProcessInventory] pi1 
                                    INNER JOIN [ProcessInventory] pi2 
                                            ON pi1.[ProcessCODE] = 
                                               pi2.[ParentProcessID]) 
                            pi 
                         ON jp.[Target] = pi.[Process_id] 
          WHERE  jp.[Status] = @isOnlyActive AND [JobCODE] = @jobid order by [Order]

          -- Get Job Step Details related to Job and Job package  
          SELECT js.[JobStepID], 
                 js.[JobStepCODE], 
                 js.[JobCODE], 
                 js.[JobPackageCODE], 
                 js.[ProcessCODE], 
                 js.[Name], 
                 js.[Descrip], 
                 js.[Order], 
                 js.[Predecessor], 
                 js.[CreatedDT], 
                 js.[Configuration], 
				 js.[Status],
                 pi.parentprocessname AS source, 
                 pi.processname       AS target, 
                 js.[Source]            AS sourceID, 
                 js.[Target]            AS targetID 
          FROM   [dbo].[JobStep] js 
                 INNER JOIN (SELECT pi2.[ProcessCODE] AS process_id, 
                                    pi1.[ProcessCODE] AS parent_process_id, 
                                    pi2.[Name]       AS Processname, 
                                    pi1.[Name]       AS ParentProcessName 
                             FROM   [ProcessInventory] pi1 
                                    INNER JOIN [ProcessInventory] pi2 
                                            ON pi1.[ProcessCODE] = 
                                               pi2.[ParentProcessID]) 
                            pi 
                         ON js.[Target] = pi.[Process_id] 
          WHERE   js.[Status] = @isOnlyActive AND [JobCODE] = @jobid 
                 AND [JobPackageCODE] IS NOT NULL order by [Order]
	  END

      END try 



      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('usp_GetSpecificJob: %d: %s',16,1,@error,@message,@lineNo); 
      END catch; 
  END;