
-- ==============================================================================
-- Author		: Arun Nair 
-- Create date	: 07/16/2015
-- Description	: Update languageid for CreativeSignature in Cinema Work Queue
-- Execution	: sp_CinemaWorkQueueUpdateLanguageForCreative 'AT&T 4G NetWork,ATL,07-06-15.jpg',1,29711029
-- Updated By	: Karunakar on 7th Sep 2015
--===============================================================================
CREATE PROCEDURE [dbo].[sp_CinemaWorkQueueUpdateLanguageForCreative]
(
@CreativeSignature AS NVARCHAR(MAX),
@LanguageId AS INTEGER,
@UserId AS INTEGER
)
AS
BEGIN
		SET NOCOUNT ON;
			  
			  BEGIN TRY
					BEGIN TRANSACTION
						-- Updating PatternMasterStgCIN Languageid and Modified By
						UPDATE [dbo].[PatternStaging] SET [LanguageID]=@LanguageId,[ModifiedDT]=getdate(),[ModifiedByID]=@UserId
						WHERE [CreativeSignature]=@CreativeSignature
					COMMIT TRANSACTION
				END TRY

				BEGIN CATCH
					DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
					SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
					RAISERROR ('[sp_CinemaWorkQueueUpdateLanguageForCreative]: %d: %s',16,1,@error,@message,@lineNo); 
					ROLLBACK TRANSACTION
				END CATCH
END