-- ========================================================================  
-- Author			: RP  
-- Create date		: 18 May 2015  
-- Execution		: [dbo].[sp_UpdatePublicationIssueStatusAsComplete] 1001
-- Description		: Update Occurrence Status  
-- Updated By		: iyub on 07/01/2015 changed ConfigurationMaster  LOV
--============================================================================   

CREATE PROCEDURE [dbo].[sp_UpdatePublicationIssueStatusAsComplete]
 (
 @PubIssueID as int
 ) 

AS 

  BEGIN 

      SET NOCOUNT ON; 

      --DECLARE @InProgressStatus AS VARCHAR(20) 
      --DECLARE @NoTakeStatus AS VARCHAR(20) 
      DECLARE @CompleteStatus AS VARCHAR(20) 
      DECLARE @InProgressStatusID AS INT
      --DECLARE @NoTakeStatusID AS INT
      --DECLARE @CompleteStatusID AS INT

      BEGIN TRY 
				BEGIN TRANSACTION				
				--Get values from ConfigurationMaster
    --            SELECT @InProgressStatus = valuetitle FROM   [Configuration] WHERE  systemname = 'All' AND componentname = 'Occurrence Status' AND value = 'P'
    --            SELECT @NoTakeStatus = valuetitle FROM   [Configuration] WHERE  systemname = 'All' AND componentname = 'Occurrence Status'  AND value = 'NT' 				 
				--SELECT @CompleteStatus = valuetitle FROM   [Configuration] WHERE  systemname = 'All'  AND componentname = 'Occurrence Status'  AND value = 'C' 

				select @InProgressStatusID = os.[OccurrenceStatusID] 
				from OccurrenceStatus os
				inner join Configuration c on os.[Status] = c.ValueTitle
				where c.SystemName = 'All' and c.ComponentName = 'Occurrence Status' AND c.Value = 'P' 

				--select @NoTakeStatusID = os.[OccurrenceStatusID] 
				--from OccurrenceStatus os
				--inner join Configuration c on os.[Status] = c.ValueTitle
				--where c.SystemName = 'All' and c.ComponentName = 'Occurrence Status' AND c.Value = 'NT' 

				--select @CompleteStatusID = os.[OccurrenceStatusID] 
				--from OccurrenceStatus os
				--inner join Configuration c on os.[Status] = c.ValueTitle
				--where c.SystemName = 'All' and c.ComponentName = 'Occurrence Status' AND c.Value = 'C' 


				select @CompleteStatus = c.ValueTitle
				from OccurrenceStatus os
				inner join Configuration c on os.[Status] = c.ValueTitle
				where c.SystemName = 'All' and c.ComponentName = 'Occurrence Status' AND c.Value = 'C' 

				 IF (@PubIssueID > 0)
				 BEGIN
					IF NOT EXISTS( SELECT 1 from [OccurrenceDetailPUB] WHERE [PubIssueID]=@PubIssueID and OccurrenceStatusID = @InProgressStatusID)
					BEGIN
						--UPDATE PubIssue SET STATUS=@CompleteStatusID WHERE [PubIssueID]=@PubIssueID and IssueCompleteIndicator=1  --- L.E. 3.16.17 MI-977 Update status to complete

						UPDATE PubIssue SET STATUS=@CompleteStatus WHERE [PubIssueID]=@PubIssueID and IssueCompleteIndicator=1
					END
				 END
				COMMIT TRANSACTION 
      END TRY
      BEGIN CATCH 
          DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
          SELECT @error = Error_number(), @message = Error_message(), @lineNo = Error_line()
          RAISERROR ('[sp_UpdatePublicationIssueStatusAsComplete]: %d: %s',16,1,@error,@message, @lineNo);
          ROLLBACK TRANSACTION 
      END CATCH

  END