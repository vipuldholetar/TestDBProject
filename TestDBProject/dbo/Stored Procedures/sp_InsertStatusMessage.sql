-- ============================================= 
-- Author:    Murali Jaganathan 
-- create date: 02/19/2015 
-- Description:  Insert Status Message
-- Query : Exec [sp_InsertStatusMessage]
-- ============================================= 

CREATE PROC [dbo].[sp_InsertStatusMessage]
@createtimestamp DATETIME,
@MessageId NVARCHAR(50),
@MessageType NVARCHAR(50),
@Priority NVARCHAR(50),
@Source NVARCHAR(100),
@Target NVARCHAR(100),
@EventType NVARCHAR(50),
@EventDetailedXML NVARCHAR(MAX)
AS 
  BEGIN 
      SET NOCOUNT ON 
			BEGIN TRY 
			-- Insert Status Message Details
				INSERT INTO [dbo].[statusmessage]
						([MessageId]
						,[CreatedDT]
						,[MessageType]
						,[Priority]
						,[Source]
						,[Target]
						,[EventType]
						,[EventDetailedxml])
					VALUES
						(@MessageId
						,@CreateTimeStamp
						,@MessageType
						,@Priority
						,@Source
						,@Target
						,@EventType
						,@EventDetailedxml)
			  END TRY 
			  BEGIN CATCH 
				DECLARE @Error   INT, 
                    @Message VARCHAR(4000), 
                    @Lineno  INT 

				SELECT @Error = Error_Number(), 
						@Message = Error_Message(), 
						@Lineno = Error_Line() 

				RAISERROR ('sp_InsertStatusMessage: %D: %S',16,1,@ERROR,@MESSAGE,@LINENO); 
			  END CATCH; 
	 END;
