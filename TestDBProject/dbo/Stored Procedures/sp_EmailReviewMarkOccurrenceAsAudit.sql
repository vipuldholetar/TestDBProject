


-- ====================================================================================================================================
-- Author		: Ramesh Bangi
-- Create date	: 10/19/2015
-- Description	: Updates the occurrence as audit 
-- Execution	:  [dbo].[sp_EmailReviewMarkOccurrenceAsAudit]
-- Updated By	: 
-- ====================================================================================================================================
 CREATE PROCEDURE [dbo].[sp_EmailReviewMarkOccurrenceAsAudit] 
(
@OccurrenceId AS INT,
@UserId AS INT
)
AS
BEGIN
	SET NOCOUNT ON;
			
	BEGIN TRY
		UPDATE dbo.[OccurrenceDetailEM] SET [AuditedByID]=@UserId,[AuditedDT]=getdate() WHERE [OccurrenceDetailEM].[OccurrenceDetailEMID]=@OccurrenceID
		UPDATE dbo.[OccurrenceDetailEM] SET [AuditedByID]=@UserId,[AuditedDT]=getdate() WHERE [OccurrenceDetailEM].[ParentOccurrenceID]=@OccurrenceID
	END TRY

	BEGIN CATCH 
				DECLARE @Error   INT,@Message VARCHAR(4000),@LineNo  INT 
				SELECT @Error = Error_number(),@Message = Error_message(),@LineNo = Error_line() 
				RAISERROR (' [dbo].[sp_EmailReviewMarkOccurrenceAsAudit]: %d: %s',16,1,@error,@message,@lineNo); 
	END CATCH   
END
