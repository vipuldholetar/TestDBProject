
-- ============================================= 
-- Author:    Rupinderjit 
-- Create date: 12/18/2014 
-- Description:  Retreiving Job details 
-- Query : exec usp_RetreiveJob  
-- ============================================= 
CREATE PROC [dbo].[usp_RetreiveJob] @processname varchar(200)
AS 
  BEGIN 
      SET nocount ON 

      BEGIN try 
          SELECT [id], 
                 [JobCODE], 
                 [ProcessCODE], 
                 [Name], 
                 [Descrip], 
                 [Status], 
                 [Type], 
                 [StartupType], 
                 [Configuration] 
          FROM   [dbo].[Job] 
          WHERE  [ProcessCODE] = @processname 

          SELECT [JobPackageID], 
                 [JobPackageCODE], 
                 [ProcessCODE], 
                 [JobCODE], 
                 [Name], 
                 [Descrip], 
                 [Order], 
                 [Predecessor], 
                 [Configuration] 
          FROM   [dbo].[JobPackage] 
          WHERE  [ProcessCODE] = @processname 

          SELECT [id], 
                 [step_id], 
                 [job_id], 
                 [job_package_id], 
                 [process_id], 
                 [name], 
                 [description], 
                 [order], 
                 [predecessor], 
                 [configuration] 
          FROM   [TMS].[dbo].[job_steps] 
          WHERE  process_id = @processname 
      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('usp_RetreiveJob: %d: %s',16,1,@error,@message,@lineNo); 
      END catch; 
  END;