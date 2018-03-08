
-- ==================================================================================
-- Author		:	Arun Nair 	
-- Create date	:	02/05/2016
-- Description	:	No Take TV  ExceptionId data
-- Execution	:	
-- Updated By	:	
-- ==================================================================================
CREATE PROCEDURE [dbo].[sp_ExceptionQueueNoTake]
(
@ExceptionList AS VARCHAR(MAX)
)
AS
BEGIN
	
	SET NOCOUNT ON;
		BEGIN TRY
				--SELECT * FROM CONFIGURATIONMASTER

				UPDATE [PatternStaging] SET NoTakeReasonCode ='No Take Miscut'
				FROM [PatternStaging]  INNER JOIN  [ExceptionDetail] ON [PatternStaging].[PatternStagingID]=[ExceptionDetail].[PatternMasterStagingID]
					WHERE [ExceptionDetail].[ExceptionDetailID] IN (select id from [dbo].[fn_CSVToTable](@ExceptionList)) 	

				UPDATE [ExceptionDetail] SET ExceptionStatus = 'Resolved  No Take'	
					WHERE [ExceptionDetail].[ExceptionDetailID]  IN (select id from [dbo].[fn_CSVToTable](@ExceptionList))
		END TRY
		BEGIN CATCH 
				DECLARE @error   INT,@message VARCHAR(4000), @lineNo  INT 
				SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				RAISERROR ('[sp_ExceptionQueueNoTake]: %d: %s',16,1,@error,@message,@lineNo);				
		END CATCH 
END