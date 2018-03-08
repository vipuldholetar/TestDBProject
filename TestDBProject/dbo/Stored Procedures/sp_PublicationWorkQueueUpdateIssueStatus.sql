CREATE PROCEDURE [dbo].[sp_PublicationWorkQueueUpdateIssueStatus] 
	@PubIssueId As Int
AS
BEGIN
	Declare @IssueCompleteInd as BIT=0
	Declare @IssueAuditInd As Bit=0
	Declare @InProgressStatus as nvarchar(max)

	SET NOCOUNT ON;
	BEGIN TRY
					    SELECT @InProgressStatus = valuetitle 
					    FROM   [Configuration] 
					    WHERE  systemname = 'All' 
							 AND componentname = 'Published Issue Status' 
							 AND value = 'P'
					BEGIN TRANSACTION
					  Update PubIssue Set IssueCompleteIndicator=@IssueCompleteInd,IssueAuditedIndicator=@IssueAuditInd,PubIssue.Status=@InProgressStatus
					  Where [PubIssueID]=@PubIssueId
					COMMIT TRANSACTION
	END TRY 
	BEGIN CATCH 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
          RAISERROR ('[sp_PublicationWorkQueueUpdateIssueStatus]: %d: %s',16,1,@error,@message,@lineNo); 
          ROLLBACK TRANSACTION 
      END CATCH 
END
