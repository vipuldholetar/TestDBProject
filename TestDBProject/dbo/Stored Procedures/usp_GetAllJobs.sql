

-- ============================================= 

-- Author:    Rupinderjit 

-- Create date: 12/18/2014 

-- Description:  Retreiving Job Details

-- Query : exec usp_GetAllJobs 'IM01', 'true'

-- ============================================= 

CREATE PROC [dbo].[usp_GetAllJobs] @processCODE varchar(20), @isOnlyActive varchar(20)

AS 

  BEGIN 

      SET nocount ON 



      BEGIN try 

	  IF(@isOnlyActive = 'false')
	  BEGIN

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
          FROM   dbo.[Job] j  inner join [ProcessInventory] pi on j.[ProcessCODE]=pi.[ProcessCODE]  where j.[ProcessCODE]=@processCODE

          
   END

   ELSE
   BEGIN
   SET @isOnlyActive = 'Active'

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
		  where j.[ProcessCODE]=@processCODE AND j.[Status] = @isOnlyActive
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