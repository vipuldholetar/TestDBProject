-- =============================================   
-- Author:    Rupinderjit   
-- Create date: 12/18/2014   
-- Description:  Retreiving Job details   
-- Query : exec [usp_GetSpecificJobbyStepID] 'JS01', 'false'  
-- =============================================   
CREATE PROC [dbo].[usp_GetSpecificJobbyStepID] @jobstepid VARCHAR(20), @isOnlyActive VARCHAR(20) 
AS 
  BEGIN 
      SET nocount ON 

      BEGIN try 
          -- Get Job Details  
      declare @jobid varchar(20)
	  declare @jobpackageid varchar(20)

	  select @jobid=[JobCODE],@jobpackageid=[JobPackageCODE] from [JobStep] where [JobStepCODE]=@jobstepid

	  
	IF(@isOnlyActive ='false')

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

				 pi.[Name] as processname ,

				 j.[Status]

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

                 pi.parentprocessname AS source, 

                 pi.processname       AS target, 

                 jp.[Source]            AS sourceID, 

                 jp.[Target]            AS targetID ,

				 jp.[Status]

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

          WHERE  [JobCODE] = @jobid and [JobPackageCODE]=@jobpackageid  order by [Order]
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

                 pi.parentprocessname AS source, 

                 pi.processname       AS target, 

                 js.[Source]            AS sourceID, 

                 js.[Target]            AS targetID ,

				 js.[Status]

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

                  and [JobPackageCODE]=@jobpackageid and [JobStepCODE]=@jobstepid  order by [Order]
      
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

				 pi.[Name] as processname ,

				 j.[Status]

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

                 pi.parentprocessname AS source, 

                 pi.processname       AS target, 

                 jp.[Source]            AS sourceID, 

                 jp.[Target]            AS targetID ,

				 jp.[Status]

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

          WHERE  jp.[Status] = @isOnlyActive AND [JobCODE] = @jobid and [JobPackageCODE]=@jobpackageid  order by [Order]
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

                 pi.parentprocessname AS source, 

                 pi.processname       AS target, 

                 js.[Source]            AS sourceID, 

                 js.[Target]            AS targetID ,

				 js.[Status]

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

          WHERE  js.[Status] = @isOnlyActive AND [JobCODE] = @jobid 

                  and [JobPackageCODE]=@jobpackageid and [JobStepCODE]=@jobstepid  order by [Order]

	END
	
       
      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('usp_GetSpecificJobbyStepID: %d: %s',16,1,@error,@message,@lineNo); 
      END catch; 
  END;