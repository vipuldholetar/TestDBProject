
-- ======================================================================================
-- Author		: Arun Nair 
-- Create date	: 11/12/2015
-- Description	: QCComplete Occurrence
-- Updated By	: 
--=======================================================================================
CREATE PROCEDURE [dbo].[sp_WebsiteUpdateOccurrenceQCComplete]
(
@OccurrenceId AS NVARCHAR(MAX)
)
AS
BEGIN
	SET NOCOUNT ON;			
			BEGIN TRY
				BEGIN TRANSACTION
					declare @CompleteStatusID int
					select @CompleteStatusID = os.[OccurrenceStatusID] 
					from OccurrenceStatus os
					inner join Configuration c on os.[Status] = c.ValueTitle
					where c.SystemName = 'All' and c.ComponentName = 'Occurrence Status' AND c.Value = 'C' 
					UPDATE [OccurrenceDetailWEB] SET QCStatusID = @CompleteStatusID  WHERE  [OccurrenceDetailWEBID] = @OccurrenceId									
					EXEC [dbo].[sp_WebsiteUpdateOccurrenceStageStatus] @OccurrenceId,4	
				COMMIT TRANSACTION
			END TRY
			BEGIN CATCH
				DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT
				SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			    RAISERROR ('[sp_WebsiteUpdateOccurrenceQCComplete]: %d: %s',16,1,@error,@message,@lineNo)   ; 
				ROLLBACK TRANSACTION 
			END CATCH

END