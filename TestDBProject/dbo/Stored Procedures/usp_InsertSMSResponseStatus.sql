

-- ============================================= 
-- AUTHOR:    MURALI JAGANATHAN 
-- CREATE DATE: 04/09/2015 
-- DESCRIPTION:  INSERT SMS MESSAGE STATUS 
-- QUERY : EXEC [usp_InsertSMSResponseStatus] <params>
-- ============================================= 

CREATE PROC [dbo].[usp_InsertSMSResponseStatus]
@CREATE_TIME_STAMP DATETIME,
@MESSAGE_ID NVARCHAR(50),
@MESSAGE_TEXT NVARCHAR(MAX),
@DESTINATION NVARCHAR(50),
@STATUS_CODE NVARCHAR(100)
AS 
  BEGIN 
      SET NOCOUNT ON 
			BEGIN TRY 
			-- INSERT SMS MESSAGE STATUS WITH DETAILS
				INSERT INTO [DBO].[STATUS_SMS]
						([CREATE_TIME_STAMP]
						,[MESSAGE_ID]
						,[MESSAGE_TEXT]
						,[DESTINATION]
						,[STATUS_CODE])
					VALUES
						(@CREATE_TIME_STAMP
						,@MESSAGE_ID
						,@MESSAGE_TEXT
						,@DESTINATION
						,@STATUS_CODE)
			  END TRY 
			  BEGIN CATCH 
				DECLARE @ERROR   INT, 
                    @MESSAGE VARCHAR(4000), 
                    @LINENO  INT 

				SELECT @ERROR = ERROR_NUMBER(), 
						@MESSAGE = ERROR_MESSAGE(), 
						@LINENO = ERROR_LINE() 

				RAISERROR ('usp_InsertSMSResponseStatus: %D: %S',16,1,@ERROR,@MESSAGE,@LINENO); 
			  END CATCH; 
	 END;
