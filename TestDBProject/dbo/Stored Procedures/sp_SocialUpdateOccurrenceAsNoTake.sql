-- =============================================================================
-- Author			: Arun Nair 
-- Create date		: 11/20/2015
-- Execution		: [dbo].[sp_SocialUpdateOccurrenceAsNoTake] 2
-- Description		: Mark Social Occurrences as NoTake
-- Updated By		: 
--					: 
--================================================================================
CREATE PROCEDURE [dbo].[sp_SocialUpdateOccurrenceAsNoTake]
 ( 
 @OccurrenceId AS INTEGER,
 @Configurationid AS INTEGER
 ) 
AS 
  BEGIN 
    SET NOCOUNT ON;
    BEGIN TRY 
				BEGIN TRANSACTION 
					--Updating Occurrence
					declare @NoTakeStatusID int
					select @NoTakeStatusID = os.[OccurrenceStatusID] 
					from OccurrenceStatus os
					inner join Configuration c on os.[Status] = c.ValueTitle
					where c.SystemName = 'All' and c.ComponentName = 'Occurrence Status' AND c.Value = 'NT' 
					UPDATE [dbo].[OccurrenceDetailSOC] 
					SET OccurrenceStatusID = @NoTakeStatusID, 
					NoTakeReason=(SELECT value FROM [Configuration] WHERE Configurationid=@Configurationid) 
					WHERE [OccurrenceDetailSOCID] =@OccurrenceId 					
				COMMIT TRANSACTION 
    END TRY 
    BEGIN CATCH 
				DECLARE @error INT,@message     VARCHAR(4000),@lineNo      INT 
				SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				RAISERROR ('[sp_SocialUpdateOccurrenceAsNoTake]: %d: %s',16,1,@error,@message,@lineNo); 
				ROLLBACK TRANSACTION 
    END CATCH 
  END