

-- ============================================= 

-- Author:    Rupinderjit 

-- Create date: 12/18/2014 

-- Description:  Retreiving Job Details of Child Processes

-- Query : exec usp_GetChildJobsbyProcessID 'SM01'

-- ============================================= 

CREATE PROC [dbo].[usp_GetChildJobsbyProcessID] @processCODE varchar(20)

AS 

  BEGIN 

      SET nocount ON 

      BEGIN try 



		-- Get All jobs related to process

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
          FROM   dbo.[Job] j  inner join [ProcessInventory] pi on j.[ProcessCODE]=pi.[ProcessCODE]  where j.[ProcessCODE] in (select [ProcessCODE] from [ProcessInventory] where [ParentProcessID]=@processCODE)


      END try 



      BEGIN catch 

          DECLARE @error   INT, 

                  @message VARCHAR(4000), 

                  @lineNo  INT 



          SELECT @error = Error_number(), 

                 @message = Error_message(), 

                 @lineNo = Error_line() 



          RAISERROR ('usp_GetChildJobsbyProcessID: %d: %s',16,1,@error,@message,@lineNo); 

      END catch; 

  END;