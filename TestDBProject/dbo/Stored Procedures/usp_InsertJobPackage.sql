
-- ============================================= 
-- Author:    Rupinderjit 
-- Create date: 12/22/2014 
-- Description:  Insert Job Package
-- Query : exec usp_InsertJobPackage
-- ============================================= 
CREATE PROC [dbo].[usp_InsertJobPackage]
 @processid varchar(20),@jobid varchar(20),@name varchar(200),@description varchar(1000),@source varchar(200),@target varchar(200),@order varchar(20),@predecessor varchar(20),@configuration varchar(max),@status nvarchar(200)
AS 
  BEGIN 
      SET nocount ON 

      BEGIN try 

	 -- Insert Job Package Details
	 declare @jobPackageID varchar(10)

	 select @jobPackageID='JP'+cast(Ident_current('job_packages')+1 as varchar)

   INSERT INTO [dbo].[JobPackage]
           ([JobPackageCODE]
           ,[ProcessCODE]
           ,[JobCODE]
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
           (@jobPackageID
           ,@processid
           ,@jobid
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

          RAISERROR ('usp_InsertJobPackage: %d: %s',16,1,@error,@message,@lineNo); 
      END catch; 
  END;
