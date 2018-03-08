-- ===================================================================================================
-- Author            : Arun Nair
-- Create date       : 01/06/2015
-- Description       : Get Occurrences in multiedition
-- EXEC              : 
-- Updated By		 : 

-- ====================================================================================================
CREATE PROCEDURE [dbo].[sp_PublicationMultiEditionOccurrenceIdList] --'01/07/16',1,0,25650
       @IssueDate VARCHAR(50),
       @PublicationID INT,
       @DefaultIndicator bit,
       @AdID INT
AS
BEGIN
       SET NOCOUNT ON;
				BEGIN TRY 
				
				SELECT Stuff((SELECT ', ' + CONVERT(NVARCHAR(MAX),[OccurrenceDetailPUB].[OccurrenceDetailPUBID] ) FROM [OccurrenceDetailPUB] 
				INNER JOIN  PubIssue  ON PubIssue.[PubIssueID]=[OccurrenceDetailPUB].[PubIssueID] 
				INNER JOIN [Market] ON  [Market].[MarketID] = [OccurrenceDetailPUB].[MarketID]
				INNER JOIN PubEdition ON PubEdition.[MarketID]=[Market].[MarketID] AND PubIssue.[PubEditionID]=PubEdition.[PubEditionID]
				WHERE PubIssue.IssueDate =@IssueDate 
					AND PubEdition.[PublicationID] = @PublicationID 
					AND PubEdition.[MNIInd] = @DefaultIndicator
					AND [OccurrenceDetailPUB] .[AdID] = @AdID
				ORDER BY [OccurrenceDetailPUB].[OccurrenceDetailPUBID] ASC FOR XML PATH('') ), 1, 2, '') AS OccurrenceIdlist			
				END TRY 
			  BEGIN CATCH 
				  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT
				  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				  RAISERROR ('[sp_PublicationMultiEditionOccurrenceIdList]: %d: %s',16,1,@error, @message,@lineNo); 
			  END CATCH 
END
