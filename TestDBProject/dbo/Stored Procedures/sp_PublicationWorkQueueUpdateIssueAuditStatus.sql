
-- ======================================================================================
-- Author		: 
-- Create date	: 
-- Description	: 
-- Updated By	: 
--	
--=======================================================================================
CREATE PROCEDURE [dbo].[sp_PublicationWorkQueueUpdateIssueAuditStatus]
		@PubIssueId As Int,
        @Id As Int
AS
BEGIN
		Declare @IssueCompleteInd as BIT=1
		Declare @IssueAuditInd As Bit=1
		DECLARE @CompleteStatus AS VARCHAR(20) 
		DECLARE @InProgressStatus AS VARCHAR(20) 

		SET NOCOUNT ON;
		BEGIN TRY		
			BEGIN TRANSACTION

			SELECT @CompleteStatus = valuetitle 
			FROM   [Configuration] 
			WHERE  systemname = 'All' 
                 AND componentname = 'Published Issue Status' 
                 AND value = 'C'

			SELECT @InProgressStatus = valuetitle 
			FROM   [Configuration] 
			WHERE  systemname = 'All' 
                 AND componentname = 'Published Issue Status' 
                 AND value = 'P'


			--Updating IssueCompleteIndicator Status
			IF(@Id=1)
			BEGIN
				Update PubIssue Set IssueCompleteIndicator=@IssueCompleteInd Where [PubIssueID]=@PubIssueId
				
				if (@pubissueid>0)
				begin
					exec [sp_UpdatePublicationIssueStatusAsComplete] @pubissueid
				end		
				End
			--Updating IssueAuditIndicator Status
				IF(@Id=2)
				BEGIN
				Update PubIssue Set IssueAuditedIndicator=@IssueAuditInd Where [PubIssueID]=@PubIssueId
				END		
			COMMIT TRANSACTION
		END TRY 
		BEGIN CATCH 
				DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
				SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				RAISERROR ('[sp_PublicationWorkQueueUpdateIssueAuditStatus]: %d: %s',16,1,@error,@message,@lineNo); 
				ROLLBACK TRANSACTION 
			END CATCH 
END
