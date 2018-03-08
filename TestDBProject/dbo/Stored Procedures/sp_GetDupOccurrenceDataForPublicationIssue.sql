-- =========================================================
-- Author		: Arun Nair 
-- Create date	: 06 June 2015 
-- Description	: Get Duplicate Data for PublicationIssue
-- Updated By	: Arun Nair On 09/June/2015
--				  Arun Nair On 16/June/2015
--=========================================================

CREATE PROCEDURE [dbo].[sp_GetDupOccurrenceDataForPublicationIssue]--5,'06/08/15'
(
@EditionID AS INT,
@IssueDate AS nvarchar(max)
--@PubIssueID  AS INT
)
AS
BEGIN

			SET NOCOUNT ON;
			BEGIN TRY
				SELECT  IssueID,IssueDate,[PublicationName],EditionName,[MediaType], [Language],[CreateBy/On],PublicationPriority As [Priority],[Status],MarketID,MarketName
				FROM [dbo].[vw_PublicationIssue] WHERE [EditionID]=@EditionID AND IssueDate in (select item from splitstring(@issuedate,','))  --AND IssueID =@PubIssueID
			END TRY

			BEGIN CATCH						
				DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
				SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				RAISERROR ('dbo.sp_GetDupOccurrenceDataForPublicationIssue: %d: %s',16,1,@error,@message,@lineNo); 
			END CATCH
END