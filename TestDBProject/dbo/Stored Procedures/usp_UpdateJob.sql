
-- ============================================= 
-- Author:    Rupinderjit 
-- Create date: 12/22/2014 
-- Description:  Update Job
-- Query : exec usp_UpdateJob
-- ============================================= 
CREATE PROC [dbo].[usp_UpdateJob]
 @processid varchar(20),@jobID varchar(20),@name varchar(200),@description varchar(1000),@status varchar(20),@type varchar(20),@startuptype varchar(20),@configuration varchar(max)
AS 
  BEGIN 
      SET nocount ON 

      BEGIN try 

	 -- Update Job Details
	
	UPDATE [dbo].[Job]
   SET 
     
      [Name] = @name
      ,[Descrip] =@description
      ,[Status] =@status
      ,[Type] = @type
      ,[StartupType] = @startuptype
      ,[Configuration] = @configuration
      
 WHERE  [JobCODE]=@jobid
  

      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('usp_UpdateJob: %d: %s',16,1,@error,@message,@lineNo); 
      END catch; 
  END;
