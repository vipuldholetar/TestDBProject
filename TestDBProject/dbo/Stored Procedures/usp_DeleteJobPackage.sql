
-- ============================================= 
-- Author:    Rupinderjit 
-- Create date: 12/22/2014 
-- Description:  Delete Job Package
-- Query : exec usp_DeleteJobPackage
-- ============================================= 
CREATE PROC [dbo].[usp_DeleteJobPackage] @jobpackageid varchar(50)
AS 
  BEGIN 
      

      BEGIN try 

	 -- Delete Job Package
	  
      Delete [JobPackage] where [JobPackageCODE]=@jobpackageid

      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('usp_DeleteJobPackage: %d: %s',16,1,@error,@message,@lineNo); 
      END catch; 
  END;
