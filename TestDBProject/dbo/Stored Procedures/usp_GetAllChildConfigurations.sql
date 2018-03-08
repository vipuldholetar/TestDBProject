
-- =============================================   
-- Author:    Rupinderjit  
-- Create date: 12/9/2014   
-- Description:  Retreive all Child Configurations  
-- Query : exec usp_GetAllChildConfigurations 
-- =============================================   
CREATE PROCEDURE [dbo].[usp_GetAllChildConfigurations] 
AS 
  BEGIN 
      SET nocount ON; 

      BEGIN try 
       SELECT [CONF_CHILD_KEY]
      ,[CONF_PARENT_KEY]
      ,[CONF_CHILD_NAME]
      ,[CONF_CHILD_DESC]
      ,[CONF_CHILD_VAL]
      ,[CREATE_DT]
      ,[CREATE_BY]
      ,[MODIFY_DT]
      ,[MODIFY_BY]
  FROM [dbo].[CONF_CHILD] 
      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('usp_GetAllChildConfigurations: %d: %s',16,1,@error, 
                     @message, 
                     @lineNo); 
      END catch; 
  END;
