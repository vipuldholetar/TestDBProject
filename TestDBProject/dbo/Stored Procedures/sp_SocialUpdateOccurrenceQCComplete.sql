-- ======================================================================================
-- Author		: Arun Nair 
-- Create date	: 11/20/2015
-- Description	: QCComplete Occurrence
-- Updated By	: 
--=======================================================================================
CREATE PROCEDURE [dbo].[sp_SocialUpdateOccurrenceQCComplete]
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
					UPDATE [OccurrenceDetailSOC] SET QCStatusID = @CompleteStatusID  WHERE  [OccurrenceDetailSOCID] = @OccurrenceId									
					EXEC [dbo].[sp_SocialUpdateOccurrenceStageStatus] @OccurrenceId,4	
				COMMIT TRANSACTION
			END TRY
			BEGIN CATCH
				DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT
				SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			    RAISERROR ('[sp_SocialUpdateOccurrenceQCComplete]: %d: %s',16,1,@error,@message,@lineNo)   ; 
				ROLLBACK TRANSACTION 
			END CATCH

END