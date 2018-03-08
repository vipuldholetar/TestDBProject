
-- ============================================= 
-- Author:    Rupinderjit 
-- Create date: 12/22/2014 
-- Description:  Update Job Step
-- Query : exec usp_UpdateJobStep
-- ============================================= 
CREATE PROC [dbo].[usp_UpdateJobStep]
 @processid varchar(20),@jobid varchar(20),@jobPackageID varchar(20),@jobStepID varchar(20), @name varchar(200),@description varchar(1000),@source varchar(200),@target varchar(200),@order varchar(20),@predecessor varchar(20),@configuration varchar(max), @status nvarchar(200)
AS 
  BEGIN 
      SET nocount ON 

      BEGIN try 

	 -- Update Job Step Details

 UPDATE [dbo].[JobStep]
   SET [Name] = @name
      ,[Descrip] = @description
      ,[Source] = @source
      ,[Target] = @target
      ,[Order] = @order
      ,[Predecessor] = @predecessor
      ,[Configuration] = @configuration
	  ,[Status] = @status
     
 WHERE [JobStepCODE]=@jobStepID

  

      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('usp_UpdateJobStep: %d: %s',16,1,@error,@message,@lineNo); 
      END catch; 
  END;
