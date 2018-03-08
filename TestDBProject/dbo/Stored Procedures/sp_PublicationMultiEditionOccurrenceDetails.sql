-- ===================================================================================================
-- Author            : Suresh,Swagatika 
-- Create date       : 12/28/2015
-- Description       : Get Occurrences in multiedition
-- EXEC              : sp_PublicationMultiEditionOccurrenceDetails '01/13/16',1,0,27667
-- Updated By		 : Arun Nair on 01/05/2016 - Take all rows of selected AdId including NoTake

-- ====================================================================================================
CREATE PROCEDURE [dbo].[sp_PublicationMultiEditionOccurrenceDetails]
       @IssueDate VARCHAR(50),
       @PublicationID INT,
       @DefaultIndicator bit,
       @AdID INT
AS
BEGIN
       SET NOCOUNT ON;

     BEGIN TRY 
                           SELECT [Market].[Descrip] AS Market,
                           [Market].Abbrevation,
                           [OccurrenceDetailPUB].[OccurrenceDetailPUBID] AS OccurrenceID,
                           (select [Status] from OccurrenceStatus where OccurrenceStatusID = [OccurrenceDetailPUB].OccurrenceStatusID) AS [Status],
                           PubIssue.[PubIssueID] AS PubIssueID,                  
                           PubEdition.EditionName AS PubEdition, 
						   PubEdition.[PubEditionID],
						   [OccurrenceDetailPUB] .[AdID],
						   PubIssue.IssueDate,
						   PubEdition.[MNIInd],
						   PubIssue.NoTakeReason,
						   [OccurrenceDetailPUB].NoTakeReason As OccurenceNoTakeReason
                           FROM [OccurrenceDetailPUB] 
                           INNER JOIN  PubIssue  ON PubIssue.[PubIssueID]=[OccurrenceDetailPUB].[PubIssueID] 
                           INNER JOIN [Market] ON  [Market].[MarketID] = [OccurrenceDetailPUB].[MarketID]
                           INNER JOIN PubEdition ON PubEdition.[MarketID]=[Market].[MarketID] 
                           AND PubIssue.[PubEditionID]=PubEdition.[PubEditionID]
                           WHERE 
                           PubIssue.IssueDate = @IssueDate
                           AND PubEdition.[PublicationID] = @PublicationID
                         AND PubIssue.NoTakeReason IS NULL        
                           AND PubEdition.[MNIInd] = @DefaultIndicator
                           AND [OccurrenceDetailPUB] .[AdID] = @AdID 
                           ORDER BY [Market].[Descrip]
         END TRY 
      BEGIN CATCH 
          DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT
          SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
          RAISERROR ('sp_PublicationMultiEditionOccurrenceDetails: %d: %s',16,1,@error, @message,@lineNo); 
      END CATCH 
       END