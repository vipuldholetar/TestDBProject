


-- ============================================= 
-- Author		: Arun Nair 
-- Create date	: 06 June 2015 
-- Description	: Check Duplicate Data for Publication Issue
-- Updated By	:

--=================================================== 

CREATE PROCEDURE [dbo].[sp_CheckDupOccurrenceDataForPubIssue] 
(
@EditionID AS INT,
@IssueDate AS nvarchar(max),
@PubIssueID AS INT
)
AS
BEGIN
			SET NOCOUNT ON;
			BEGIN TRY
				SELECT Count(1) AS RecordsCount FROM [dbo].[vw_PublicationIssue] 
				WHERE [EditionID]=@EditionID AND IssueDate in (select item from splitstring(@issuedate,',')) AND SenderID = @PubIssueID
			END TRY

			BEGIN CATCH						
				DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
				SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				RAISERROR ('dbo.sp_CheckDupOccurrenceDataForPubIssue: %d: %s',16,1,@error,@message,@lineNo); 
			END CATCH

END