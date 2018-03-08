
-- ======================================================================================
-- Author		: Arun Nair 
-- Create date	: 11/04/2015
-- Description	: QCComplete Parent and Child Occurrences
-- Updated By	: 
--=======================================================================================
CREATE PROCEDURE [dbo].[sp_EmailUpdateOccurrenceQCComplete]
(
@ParentOccurrenceId AS NVARCHAR(MAX)
)
AS
BEGIN
	SET NOCOUNT ON;			
			BEGIN TRY
				BEGIN TRANSACTION
					--DECLARE @Status VARCHAR(50)
					--SELECT @Status=ValueTitle  FROM   [Configuration]  WHERE SystemName='All' and Componentname='Occurrence Status' and Value='C'
					declare @StatusID int
					select @StatusID = os.[OccurrenceStatusID] 
					from OccurrenceStatus os
					inner join Configuration c on os.[Status] = c.ValueTitle
					where c.SystemName = 'All' and c.ComponentName = 'Occurrence Status' AND c.Value = 'C' 
					UPDATE [OccurrenceDetailEM] SET QCStatusID = @StatusID  WHERE  [ParentOccurrenceID] = @ParentOccurrenceId
					UPDATE [OccurrenceDetailEM] SET QCStatusID = @StatusID  WHERE [OccurrenceDetailEMID]=@ParentOccurrenceId					
					EXEC [dbo].[sp_EmailUpdateOccurrenceStageStatus] @ParentOccurrenceId,4	
				COMMIT TRANSACTION
			END TRY

			BEGIN CATCH
				DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT
				SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			    RAISERROR ('[sp_EmailUpdateOccurrenceQCComplete]: %d: %s',16,1,@error,@message,@lineNo)   ; 
				ROLLBACK TRANSACTION 
			END CATCH

END