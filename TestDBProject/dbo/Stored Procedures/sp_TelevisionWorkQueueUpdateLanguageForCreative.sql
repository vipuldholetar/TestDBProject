-- ====================================================================================
-- Author		: Murali 
-- Create date	: 07/07/2015
-- Description	: Update languageid for CreativeSignature in TV Work Queue
-- Updated By	: Karunakar on 14th Sep 2015
--=================================================================================
CREATE PROCEDURE [dbo].[sp_TelevisionWorkQueueUpdateLanguageForCreative]
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

						-- Updating LanguageId in PatternMasterStgTV 
						UPDATE [dbo].[PatternStaging] SET [LanguageID]=@LanguageId--,[ModifiedDTM]=getdate(),[ModifiedBy]=@UserId
						WHERE [CreativeSignature]=@CreativeSignature

					COMMIT TRANSACTION
				END TRY

				BEGIN CATCH
					DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
					SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
					RAISERROR ('sp_TelevisionWorkQueueUpdateLanguageForCreative: %d: %s',16,1,@error,@message,@lineNo); 
					ROLLBACK TRANSACTION
				END CATCH
END