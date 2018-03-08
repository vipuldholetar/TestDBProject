
-- =============================================   
-- Author:    Ganesh   
-- alter date: 07/12/2015   
-- Description:  Cleanup Website Records   
-- Execution :  Exec sp_CleanupWebsite 
-- =============================================   
CREATE PROCEDURE [dbo].[sp_CleanupWebsite] 
AS 
  BEGIN 
      BEGIN try 
          BEGIN TRANSACTION 

          DECLARE @MediastreamID AS INT=0 

          SELECT @MediastreamID = configurationid 
          FROM   [Configuration] 
          WHERE  componentname = 'Media Stream' 
                 AND value = 'WEB' 

          IF @MediastreamID > 0 
            BEGIN 
                -- Removing the Pattern and Ad mapping 
                UPDATE [OccurrenceDetailWEB] 
                SET    [PatternID] = NULL, 
                       [AdID] = NULL 

                -- Remove Creative details for Website 
                DELETE FROM [dbo].[creativedetailweb] 

                -- Remove Creative Master Records for Website 
                DELETE FROM [dbo].[Creative] 
                WHERE  [AdId] IN (SELECT [AdID] 
                                   FROM   [dbo].[Pattern] 
                                   WHERE  mediastream = @MediastreamID 
                                          AND [AdID] IS NOT NULL) 

                -- Remove Website  Ad's 
                DELETE FROM ad 
                WHERE  [AdID] IN (SELECT [AdID] 
                                 FROM   [dbo].[Pattern] 
                                 WHERE  mediastream = @MediastreamID) 

                -- Remove Pattern Master Data 
                DELETE FROM [dbo].[Pattern] 
                WHERE  mediastream = @MediastreamID 

                -- Remove Website Occurrences 
                DELETE FROM [OccurrenceDetailWEB] 

                -- Remove Query Details for Website 
                DELETE FROM [QueryDetail] 
                WHERE  [MediaStreamID] = 'WEB' 
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

          RAISERROR ('[sp_CleanupWebsite]: %d: %s',16,1,@ERROR,@MESSAGE,@LINENO 
          ); 

          ROLLBACK TRANSACTION 
      END catch 
  END
