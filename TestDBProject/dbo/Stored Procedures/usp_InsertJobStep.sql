
-- ============================================= 
-- Author:    Rupinderjit 
-- Create date: 12/22/2014 
-- Description:  Insert Job Step
-- Query : exec usp_InsertJobStep
-- ============================================= 
CREATE PROC [dbo].[usp_InsertJobStep]
 @processid varchar(20),@jobid varchar(20),@jobpackageid varchar(20),@name varchar(200),@description varchar(1000),@source varchar(200),@target varchar(200),@order varchar(20),@predecessor varchar(20),@configuration varchar(max),@status nvarchar(200)
AS 
  BEGIN 
      SET nocount ON 

      BEGIN try 

	 -- Insert Job Step Details
	 declare @jobStepID varchar(10)

	 select @jobStepID='JS'+cast(Ident_current('job_steps')+1 as varchar)

    INSERT INTO [dbo].[JobStep]
           ([JobStepCODE]
           ,[JobCODE]
           ,[JobPackageCODE]
           ,[ProcessCODE]
           ,[Name]
           ,[Descrip]
           ,[Source]
           ,[Target]
           ,[Order]
           ,[Predecessor]
           ,[Configuration]
           ,[CreatedDT]
		   ,[Status])
     VALUES     
           (@jobStepID
           ,@jobid
           ,@jobpackageid
           ,@processid
           ,@name
           ,@description
           ,@source
           ,@target
           ,@order
           ,@predecessor
           ,@configuration
           ,getdate()
		   ,@status)

      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('usp_InsertJobStep: %d: %s',16,1,@error,@message,@lineNo); 
      END catch; 
  END;
