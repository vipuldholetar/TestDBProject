

-- ============================================= 
-- Author:    Murali 
-- Create date: 03/24/2015 
-- Description:  Retreiving Status 
-- Query : exec  usp_GetStatusbyServiceName 'ServiceName'
-- ============================================= 
CREATE PROC [dbo].[usp_GetStatusbyServiceName] @servicename nvarchar(max)
AS 
  BEGIN 
      SET nocount ON 
      BEGIN try 

		-- Get status, based on provided service name 
		select [Status] from [ProcessInventory] where [Name]  = @servicename

      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('usp_GetStatusbyServiceName: %d: %s',16,1,@error,@message,@lineNo); 
      END catch; 
  END;
