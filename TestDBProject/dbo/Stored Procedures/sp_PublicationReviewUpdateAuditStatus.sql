-- =============================================
-- Author:		Murali Jaganathan
-- Create date: 23/06/2015
-- Description:	This Procedure is used to update the audit status of the Pub Issue
-- =============================================

CREATE PROCEDURE  [dbo].[sp_PublicationReviewUpdateAuditStatus]
	@UserName varchar(200),
	@PubIssueID int

AS
BEGIN
	
	Declare @IssueAuditInd As Bit = 1
	SET NOCOUNT ON;

	BEGIN TRY	

	   Update PubIssue Set IssueAuditedIndicator = @IssueAuditInd,AuditBy= @UserName,AuditDTM = getdate()
	   Where [PubIssueID] = @PubIssueId

    END TRY 
   		BEGIN CATCH 
				DECLARE @error   INT, 
						@message VARCHAR(4000), 
						@lineNo  INT 

				SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				RAISERROR ('[sp_PublicationReviewUpdateAuditStatus]: %d: %s',16,1,@error,@message,@lineNo); 
				ROLLBACK TRANSACTION 
			END CATCH 
END
