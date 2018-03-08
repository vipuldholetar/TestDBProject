
-- =============================================   
-- Author:    Ganesh   
-- alter date: 07/12/2015   
-- Description:  Cleanup Social Records   
-- Execution :  Exec sp_CleanupSocial 
-- =============================================   
CREATE PROCEDURE [dbo].[sp_CleanupSocial] 
AS 
  BEGIN 
      BEGIN try 
          BEGIN TRANSACTION 

          DECLARE @MediastreamID AS INT=0 

          SELECT @MediastreamID = configurationid 
          FROM   [Configuration] 
          WHERE  componentname = 'Media Stream' 
                 AND value = 'SOC' 

          IF @MediastreamID > 0 
            BEGIN 
                -- Removing the Pattern and Ad mapping 
                UPDATE [OccurrenceDetailSOC] 
                SET    [PatternID] = NULL, 
                       [AdID] = NULL 

                -- Remove Creative details for Social 
                DELETE FROM [dbo].[creativedetailsoc] 

                -- Remove Creative Master Records for Social 
                DELETE FROM [dbo].[Creative] 
                WHERE  [AdId] IN (SELECT [AdID] 
                                   FROM   [dbo].[Pattern] 
                                   WHERE  mediastream = @MediastreamID 
                                          AND [AdID] IS NOT NULL) 

                -- Remove Social  Ad's 
                DELETE FROM ad 
                WHERE  [AdID] IN (SELECT [AdID] 
                                 FROM   [dbo].[Pattern] 
                                 WHERE  mediastream = @MediastreamID) 

                -- Remove Pattern Master Data 
                DELETE FROM [dbo].[Pattern] 
                WHERE  mediastream = @MediastreamID 

                -- Remove Website Occurrences 
                DELETE FROM [OccurrenceDetailSOC] 

                -- Remove Query Details for Social 
                DELETE FROM [QueryDetail] 
                WHERE  [MediaStreamID] = 'SOC' 
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

          RAISERROR ('[sp_CleanupSocial]: %d: %s',16,1,@ERROR,@MESSAGE,@LINENO ) 
          ; 

          ROLLBACK TRANSACTION 
      END catch 
  END
