-- ================================================================================
-- Author		: Arun Nair 
-- Create date	: 12/30/2015
-- Description	: Get First PubIssueId 
-- Execution	: sp_PublicationMultiEditionGetFirstPubIssue 6,'2016-01-01' 
-- Updated By	:
-- ===============================================================================
CREATE PROCEDURE  [dbo].[sp_PublicationMultiEditionGetFirstPubIssue]  
(
@PublicationID INT,
@IssueDate AS VARCHAR(50)=''
)

AS
BEGIN	
	SET NOCOUNT ON;
					  DECLARE @SQLStmnt AS NVARCHAR(MAX)='' 
					  DECLARE @SelectStmnt AS NVARCHAR(MAX)='' 
					  DECLARE @Where AS NVARCHAR(MAX)=''      
					  DECLARE @Groupby AS NVARCHAR(MAX)=''      
					  DECLARE @Orderby AS NVARCHAR(MAX)='' 
					  DECLARE @OccurrenceStatus AS NVARCHAR(10)

				BEGIN TRY
						SET @SelectStmnt='SELECT  TOP 1 PubIssue.PubIssueID AS IssueId,PubIssue.IssueDate,PubEdition.EditionName,Publication.Descrip As PublicationName 
						FROM Publication INNER JOIN PubEdition ON Publication.PublicationId=PubEdition.PublicationID
						INNER JOIN PubIssue ON PubEdition.PubEditionID= PubIssue.PubEditionID '

						SET @Where =' Where 1=1 '

						IF(@PublicationID<>0)
							BEGIN
								SET @Where= @where + 'AND Publication.PublicationId= '+CONVERT(NVARCHAR,@PublicationId)+ ' '
							END 
						IF(@IssueDate<>'')
							BEGIN
								SET @Where= @where + 'AND PubIssue.IssueDate='''+convert(varchar,cast(@IssueDate as date),110) +''' '
							END 

						SET @Orderby='ORDER BY PubIssueID ASC'

						SET @SQLStmnt=@SelectStmnt + @Where + @Orderby 
						--PRINT @SQLStmnt
						EXECUTE Sp_executesql @SQLStmnt 
						
					
			END TRY
			BEGIN CATCH
						DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
						SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
						RAISERROR ('[sp_PublicationMultiEditionGetFirstPubIssue]: %d: %s',16,1,@error,@message,@lineNo);
			END CATCH

				    
END