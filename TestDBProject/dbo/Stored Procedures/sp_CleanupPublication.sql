
-- =============================================   
-- Author:    Ganesh   
-- alter date: 07/12/2015   
-- Description:  Cleanup Publication Records   
-- Execution :  Exec sp_CleanupPublication 
-- =============================================   
CREATE PROCEDURE [dbo].[sp_CleanupPublication] 
AS 
  BEGIN 
      BEGIN try 
          BEGIN TRANSACTION 

          DECLARE @MediastreamID AS INT=0 

          SELECT @MediastreamID = configurationid 
          FROM   [Configuration] 
          WHERE  componentname = 'Media Stream' 
                 AND value = 'Pub' 

          IF @MediastreamID > 0 
            BEGIN 
                --Removing the Pattern and Ad mapping 
                UPDATE [OccurrenceDetailPUB] 
                SET    [PatternID] = NULL, 
                       [AdID] = NULL 

                --Remove Creative details for Publication 
                DELETE FROM [dbo].[creativedetailpub] 

                --Remove Creative Master Records for Publication 
                DELETE FROM [dbo].[Creative] 
                WHERE  [AdId] IN (SELECT [AdID] 
                                   FROM   [dbo].[Pattern] 
                                   WHERE  mediastream = @MediastreamID 
                                          AND [AdID] IS NOT NULL) 

                -- Remove Publication  Ad's 
                DELETE FROM ad 
                WHERE  [AdID] IN (SELECT [AdID] 
                                 FROM   [dbo].[Pattern] 
                                 WHERE  mediastream = @MediastreamID) 

                -- Remove Pattern Master Data 
                DELETE FROM [dbo].[Pattern] 
                WHERE  mediastream = @MediastreamID 

                -- Remove Publication Occurrences 
                DELETE FROM [OccurrenceDetailPUB] 

                --Removing the PubIssue  Data 
                DELETE FROM pubissue 
                WHERE  [PubIssueID] IN (SELECT [PubIssueID] 
                                         FROM   [OccurrenceDetailPUB]) 

                -- Remove Query Details for Publication 
                DELETE FROM [QueryDetail] 
                WHERE  [MediaStreamID] = 'PUB' 
            END 

          COMMIT TRANSACTION 
      END try 

      BEGIN catch 
          DECLARE @ERROR   INT, 
                  @MESSAGE VARCHAR(4000), 
                  @LINENO  INT 

          SELECT @ERROR = Error_number(), 
                 @MESSAGE = Error_message(), 
                 @LINENO = Error_line() 

          RAISERROR ('[sp_CleanupPublication]: %d: %s',16,1,@ERROR,@MESSAGE, 
                     @LINENO ); 

          ROLLBACK TRANSACTION 
      END catch 
  END
