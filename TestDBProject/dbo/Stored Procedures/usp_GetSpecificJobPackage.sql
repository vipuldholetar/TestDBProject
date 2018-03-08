
-- ============================================= 
-- Author:    Rupinderjit 
-- Create date: 12/18/2014 
-- Description:  Retreiving Job details 
-- Query : exec usp_GetSpecificJobPackage  'JP01'
-- ============================================= 
CREATE PROC [dbo].[usp_GetSpecificJobPackage] @jobpackageid varchar(20)
AS 
  BEGIN 
      SET nocount ON 

      BEGIN try 
        
		SELECT [JobPackageID]
      ,[JobPackageCODE]
      ,[ProcessCODE]
      ,[JobCODE]
      ,[Name]
      ,[Descrip]
      ,[Order]
      ,[Predecessor]
      ,[Configuration]
	  ,[Status]
  FROM [dbo].[JobPackage] where [JobPackageCODE]=@jobPackageID

          SELECT [JobStepID], 
                 [JobStepCODE], 
                 [JobCODE], 
                 [JobPackageCODE], 
                 [ProcessCODE], 
                 [Name], 
                 [Descrip], 
                 [Order], 
                 [Predecessor], 
                 [Configuration] ,
				 [Status]
          FROM   [dbo].[JobStep] 
          WHERE  [JobPackageCODE] = @jobpackageid 
      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('usp_GetSpecificJobPackage: %d: %s',16,1,@error,@message,@lineNo); 
      END catch; 
  END;
