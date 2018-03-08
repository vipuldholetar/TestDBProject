
-- =============================================   
-- Author:    Ganesh   
-- alter date: 07/12/2015   
-- Description:  Cleanup Email Records   
-- Execution :  Exec sp_CleanupEmail   
-- =============================================   
CREATE PROCEDURE [dbo].[Sp_Cleanupemail] 
AS 
  BEGIN 
      BEGIN try 
          BEGIN TRANSACTION 

          DECLARE @MediastreamID AS INT=0 

          SELECT @MediastreamID = configurationid 
          FROM   [Configuration] 
          WHERE  componentname = 'Media Stream' 
                 AND value = 'EM' 

          IF @MediastreamID > 0 
            BEGIN 
                -- Removing the Pattern and Ad mapping  
                UPDATE [OccurrenceDetailEM] 
                SET    [PatternID] = NULL, 
                       [AdID] = NULL 

                -- Remove Creative details for Email  
                DELETE FROM [dbo].[creativedetailem] 

                -- Remove Creative Master Records for Email  
                DELETE FROM [dbo].[Creative] 
                WHERE  [AdId] IN (SELECT [AdID] 
                                   FROM   [dbo].[Pattern] 
                                   WHERE  mediastream = @MediastreamID 
                                          AND [AdID] IS NOT NULL) 

                -- Remove Email  Ad's  
                DELETE FROM ad 
                WHERE  [AdID] IN (SELECT [AdID] 
                                 FROM   [dbo].[Pattern] 
                                 WHERE  mediastream = @MediastreamID) 

                -- Remove Pattern Master Data  
                DELETE FROM [dbo].[Pattern] 
                WHERE  mediastream = @MediastreamID 

                -- Remove Email Occurrences  
                DELETE FROM [OccurrenceDetailEM] 

                -- Remove Query Details for Email  
                DELETE FROM [QueryDetail] 
                WHERE  [MediaStreamID] = 'EM' 
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

          RAISERROR ('[sp_CleanupEmail]: %d: %s',16,1,@ERROR,@MESSAGE,@LINENO ); 

          ROLLBACK TRANSACTION 
      END catch 
  END
