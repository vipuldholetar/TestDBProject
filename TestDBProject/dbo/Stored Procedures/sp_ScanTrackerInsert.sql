
-- ============================================================================

-- Author		: Arun Nair   
-- Create date  : 7th Dec 2015   
-- Description  : Process Scanned Files 
-- Exec			: sp_ScanTrackerInsert
-- Updated By	: 
--=============================================================================

CREATE PROCEDURE [dbo].[sp_ScanTrackerInsert]
	@OccurrenceId bigint,
	@imageName varchar(50),
	@UserID int
AS
BEGIN
	SET NOCOUNT ON;
		BEGIN TRY
			BEGIN TRANSACTION
				INSERT INTO ScanTracker([UserID], [OccurrenceID], ImageName) VALUES(@UserID,@OccurrenceId,@imageName)
			COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			 DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
			 SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			 RAISERROR ('[sp_ScanTrackerInsert]: %d: %s',16,1,@error,@message,@lineNo); 
			 ROLLBACK TRANSACTION
		END CATCH

END
