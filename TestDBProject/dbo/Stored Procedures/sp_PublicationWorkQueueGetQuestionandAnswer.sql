

-- ====================================================================
-- Author:		Arun Nair 
-- Create date: 06/15/2015
-- Description:	This stored procedure is used to fill the Q AND A in Publication Work Queue Issue List	
-- Exec sp_PublicationWorkQueueGetQuestionandAnswer 5127
-- Updated By : Arun Nair  For QandA
-- Updated for MI-918 L.E. occurrence level queries
-- =====================================================================

CREATE PROCEDURE [dbo].[sp_PublicationWorkQueueGetQuestionandAnswer]
(
@PubIssueId AS INTEGER, 
@OccurrenceId AS INTEGER =0
)
AS
BEGIN
		SET NOCOUNT ON;
		SET CONCAT_NULL_YIELDS_NULL OFF;

		BEGIN TRY
			If @OccurrenceId > 0
			BEGIN 
				SELECT [dbo].[QueryDetail].QueryText ,[dbo].[QueryDetail].[QryAnswer] 
				FROM dbo.OccurrenceDetailPUB Left Join [QueryDetail] On [QueryDetail].Occurrenceid=dbo.OccurrenceDetailPUB.OccurrenceDetailPUBid
				WHERE dbo.OccurrenceDetailPUB.OccurrenceDetailPUBid=@OccurrenceId AND [QueryDetail].QueryText is not null
			END
			ELSE
			BEGIN
				SELECT [dbo].[QueryDetail].QueryText ,[dbo].[QueryDetail].[QryAnswer] 
				FROM dbo.PubIssue Left Join [QueryDetail] On [QueryDetail].[PubIssueID]=dbo.PubIssue.[PubIssueID]
				WHERE dbo.PubIssue.[PubIssueID]=@PubIssueId and [QueryDetail].QueryText is not null
			END
				
		END TRY

		BEGIN CATCH
		DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
		SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
		RAISERROR ('[sp_PublicationWorkQueueGetQuestionandAnswer]: %d: %s',16,1,@error,@message,@lineNo);
		END CATCH
END 