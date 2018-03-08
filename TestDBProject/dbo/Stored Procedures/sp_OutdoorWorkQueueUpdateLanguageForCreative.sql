
-- ====================================================================================
-- Author		: Arun Nair 
-- Create date	: 07/07/2015
-- Description	: Update languageid for CreativeSignature in Outdoor Work Queue
-- Updated By	: Arun Nair for ModifiedDTM,ModifiedBy	
--=================================================================================
CREATE PROCEDURE [dbo].[sp_OutdoorWorkQueueUpdateLanguageForCreative]--'AT&T 4G NetWork,ATL,07-06-15.jpg',1
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
						UPDATE [dbo].[PatternStaging] SET [LanguageID]=@LanguageId,[ModifiedDT]=getdate(),[ModifiedByID]=@UserId
						WHERE [CreativeSignature]=@CreativeSignature
					COMMIT TRANSACTION
				END TRY

				BEGIN CATCH
					DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
					SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
					RAISERROR ('sp_OutdoorWorkQueueUpdateLanguageForCreative: %d: %s',16,1,@error,@message,@lineNo); 
					ROLLBACK TRANSACTION
				END CATCH
END