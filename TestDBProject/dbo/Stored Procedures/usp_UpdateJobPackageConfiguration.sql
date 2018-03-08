
-- ============================================= 
-- Author:    Rupinderjit 
-- Create date: 12/22/2014 
-- Description:  Update Job Package Configuration
-- Query : exec usp_UpdateJobPackageConfiguration
-- ============================================= 
CREATE PROC [dbo].[usp_UpdateJobPackageConfiguration] @jobpackageid varchar(20),@configuration nvarchar(max)
AS 
  BEGIN 
      SET nocount ON 

      BEGIN try 

	 -- Update Job Configuration

      Update [JobPackage] set [Configuration]=@configuration where [JobPackageCODE]=@jobpackageid

      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('usp_UpdateJobPackageConfiguration: %d: %s',16,1,@error,@message,@lineNo); 
      END catch; 
  END;
