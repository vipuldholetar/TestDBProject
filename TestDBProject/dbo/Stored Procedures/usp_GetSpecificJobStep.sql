
-- ============================================= 
-- Author:    Rupinderjit 
-- Create date: 12/18/2014 
-- Description:  Retreiving Job Names related to a process 
-- Query : exec usp_GetSpecifiJobStep 'JS01'
-- ============================================= 
CREATE PROC [dbo].[usp_GetSpecificJobStep] @jobStepID varchar(20)
AS 
  BEGIN 
      SET nocount ON 

      BEGIN try 

		-- Get Job Step Details
       SELECT  [JobStepID]
      ,[JobStepCODE]
      ,[JobCODE]
      ,[JobPackageCODE]
      ,[ProcessCODE]
      ,[Name]
      ,[Descrip]
      ,[Order]
      ,[Predecessor]
      ,[Configuration]
	  ,[Status]
  FROM [dbo].[JobStep] where [JobStepCODE]=@jobStepID 

      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('usp_GetSpecifiJobStep: %d: %s',16,1,@error,@message,@lineNo); 
      END catch; 
  END;
