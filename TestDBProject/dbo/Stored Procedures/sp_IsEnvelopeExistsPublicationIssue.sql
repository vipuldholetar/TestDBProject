
-- ============================================= 
-- Author		: Arun Nair 
-- Create date	: 10 June 2015 
-- Description	: EnvelopeID Exists for Publication Issue
-- Updated By	:
--=================================================== 
CREATE PROCEDURE sp_IsEnvelopeExistsPublicationIssue
(
@EnvelopeId AS INT
)
AS
BEGIN
	SET NOCOUNT ON; 
			BEGIN TRY
		IF EXISTS(SELECT [EnvelopeID] FROM [dbo].[Envelope] WHERE [EnvelopeID]=@EnvelopeId)
			BEGIN
				SELECT 1 AS RESULT
			END
		ELSE
			BEGIN
				SELECT 0 AS RESULT
			END
			END TRY

			BEGIN CATCH
				  DECLARE @error INT,@message     VARCHAR(4000),@lineNo      INT 
				  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line()
				  RAISERROR ('sp_IsEnvelopeExistsPublicationIssue: %d: %s',16,1,@error,@message,@lineNo); 
				  ROLLBACK TRANSACTION 
			END CATCH


END
