-- ===========================================================================================
-- Author                         :      Asit
-- Create date                    :      29/10/2015
-- Description                    :      This stored procedure is used for getting Key elements data
-- Execution Process              :      [dbo].[sp_GetKeyElementComboboxItems]
-- Updated By                     :      
-- ============================================================================================


CREATE PROCEDURE [dbo].[sp_GetKeyElementComboboxItems] 
	@SystemName VARCHAR(50),
	@ComponentName VARCHAR(50)
AS 
  BEGIN 
      BEGIN TRY 

	  SELECT ConfigurationID,Value,ValueTitle,ValueGroup FROM [Configuration] 
	  WHERE SystemName= @SystemName 
	  AND ComponentName = @ComponentName

      END TRY 

      BEGIN CATCH 

          DECLARE @error   INT,
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('sp_GetKeyElementComboboxItems: %d: %s',16,1,@error,@message,@lineNo); 
		  
      END CATCH; 

  END;
