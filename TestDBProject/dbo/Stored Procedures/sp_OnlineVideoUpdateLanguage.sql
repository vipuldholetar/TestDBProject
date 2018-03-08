-- ==============================================================================
-- Author		: Ramesh Bangi 
-- Create date	: 07/16/2015
-- Description	: Update LanguageId for CreativeSignature in Online Video Work Queue
-- Execution	: [dbo].[sp_OnlineVideoUpdateLanguage]
-- Updated By	: 
--===============================================================================
CREATE PROCEDURE [dbo].[sp_OnlineVideoUpdateLanguage]
(
@CreativeSignature AS NVARCHAR(MAX),
@LanguageId AS INTEGER,
@UserId AS INTEGER
)
AS
BEGIN
		SET NOCOUNT ON;		
					DECLARE @CreativeMasterStgid AS INT 
			  
			  BEGIN TRY
				BEGIN TRANSACTION
					
					--Updating PatternMasterStg LanguageId and Modified By
					SELECT @CreativeMasterStgid=[CreativeStagingID] from [CreativeStaging] Where CreativeSignature=@CreativeSignature
					UPDATE [dbo].[PatternStaging] SET [LanguageID]=@LanguageId,[ModifiedDT]=getdate(),[ModifiedByID]=@UserId WHERE [CreativeStgID]=@CreativeMasterStgid

				COMMIT TRANSACTION
				END TRY
				BEGIN CATCH
					DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
					SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
					RAISERROR ('[dbo].[sp_OnlineVideoUpdateLanguage]: %d: %s',16,1,@error,@message,@lineNo); 
					ROLLBACK TRANSACTION
				END CATCH
END