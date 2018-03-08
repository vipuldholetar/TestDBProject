-- =====================================================================================
-- Author			: Arun Nair 
-- Create date		: 12/30/2015
-- Description		: Search MultiEdition   
-- Execution		: [sp_PublicationMultiEditionCheckUncheckMarket] 50,1,'2015-12-11',0
-- Updated By 
-- ======================================================================================


CREATE PROCEDURE [dbo].[sp_PublicationMultiEditionCheckUncheckMarket] 
(
@MarketId AS INTEGER,
@PublicationId AS INTEGER,
@IssueDate AS VARCHAR(50)='',
@MNIIndicator AS INTEGER
)
AS
BEGIN
		declare @NoTakeStatusID int
		select @NoTakeStatusID = os.[OccurrenceStatusID] 
		from OccurrenceStatus os
		inner join Configuration c on os.[Status] = c.ValueTitle
		where c.SystemName = 'All' and c.ComponentName = 'Occurrence Status' AND c.Value = 'NT' 
		
		BEGIN TRY
          IF EXISTS(SELECT [OccurrenceDetailPUB].[OccurrenceDetailPUBID]   FROM [OccurrenceDetailPUB] 
							INNER JOIN PubIssue ON PubIssue.[PubIssueID]=[OccurrenceDetailPUB].[PubIssueID]
							INNER JOIN PubEdition ON PubEdition.[PubEditionID]= PubIssue.[PubEditionID]
							WHERE PubEdition.[PubEditionID] = PubIssue.[PubEditionID]
							AND PubEdition.[PublicationID] = @PublicationId
							AND PubIssue.IssueDate = @IssueDate
							AND [OccurrenceDetailPUB].[PubIssueID] = PubIssue.[PubIssueID]
							AND [OccurrenceDetailPUB].OccurrenceStatusID != @NoTakeStatusID
							AND PubEdition.[MarketID] = @MarketId
							AND PubEdition.[MNIInd] = @MNIIndicator
					)			
					BEGIN --Check the Market checkbox
						 SELECT 1 AS Result 
					END 
            ELSE
					BEGIN  ---UnCheck the Market checkbox>
						SELECT 0 AS RESULT 
					END 
			
		  END TRY

		  BEGIN CATCH
				DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
				SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				RAISERROR ('[sp_PublicationMultiEditionCheckUncheckMarket]: %d: %s',16,1,@error,@message,@lineNo);
		  END CATCH


END