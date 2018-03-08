-- ====================================================================================================================================
-- Author		: Ramesh Bangi
-- Create date	: 11/20/2015
-- Description	: Updates the occurrence as audit 
-- Execution	:  [dbo].[sp_WebsiteReviewMarkOccurrenceAsAudit]
-- Updated By	: 
-- ====================================================================================================================================
 CREATE PROCEDURE [dbo].[sp_WebsiteReviewMarkOccurrenceAsAudit] 
(
@OccurrenceId AS INT,
@UserId AS INT
)
AS
BEGIN
	SET NOCOUNT ON;
			
	BEGIN TRY
		UPDATE dbo.[OccurrenceDetailWEB] SET [AuditedByID]=@UserId,[AuditedDT]=getdate() WHERE [OccurrenceDetailWEB].[OccurrenceDetailWEBID]=@OccurrenceID
	END TRY

	BEGIN CATCH 
				DECLARE @Error   INT,@Message VARCHAR(4000),@LineNo  INT 
				SELECT @Error = Error_number(),@Message = Error_message(),@LineNo = Error_line() 
				RAISERROR (' [dbo].[sp_WebsiteReviewMarkOccurrenceAsAudit]: %d: %s',16,1,@error,@message,@lineNo); 
	END CATCH   
END
