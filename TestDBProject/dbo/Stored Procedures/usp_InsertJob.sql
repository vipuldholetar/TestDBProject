
-- ============================================= 
-- Author:    Rupinderjit 
-- Create date: 12/22/2014 
-- Description:  Insert Job
-- Query : exec usp_InsertJob
-- ============================================= 
CREATE PROC [dbo].[usp_InsertJob]
 @processid varchar(20),@name varchar(200),@description varchar(1000),@status varchar(20),@type varchar(20),@startuptype varchar(20),@configuration varchar(max)
AS 
  BEGIN 
      SET nocount ON 

      BEGIN try 

	 -- Insert Job Details
	 declare @jobid varchar(10)
	  select @jobid='JB'+cast(Ident_current('jobs')+1 as varchar)

    INSERT INTO [dbo].[Job]
           ([JobCODE]
           ,[ProcessCODE]
           ,[Name]
           ,[Descrip]
           ,[Status]
           ,[Type]
           ,[StartupType]
           ,[Configuration]
           ,[CreateDT])
     VALUES
           (@jobid
           ,@processid
           ,@name
           ,@description
           ,@status
           ,@type
           ,@startuptype
           ,@configuration
           ,getdate())

      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('usp_InsertJob: %d: %s',16,1,@error,@message,@lineNo); 
      END catch; 
  END;