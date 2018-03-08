
-- =============================================   
-- Author:    Ganesh   
-- alter date: 07/12/2015   
-- Description:  Cleanup TV Records   
-- Execution :  Exec sp_CleanupTV 
-- =============================================   
CREATE PROCEDURE [dbo].[sp_CleanupTV] 
AS 
  BEGIN 
      BEGIN try 
          BEGIN TRANSACTION 

          DECLARE @MediastreamID AS INT=0 

          SELECT @MediastreamID = configurationid 
          FROM   [Configuration] 
          WHERE  componentname = 'Media Stream' 
                 AND value = 'TV' 

          IF @MediastreamID > 0 
            BEGIN 
                -- Removing the Pattern and Ad mapping 
                UPDATE [OccurrenceDetailTV] 
                SET    [PatternID] = NULL, 
                       [AdID] = NULL 

                -- Removes the CreativeDetails of TV 
                DELETE FROM [dbo].[creativedetailtv] 

                -- Remove Creative Master Records for TV 
                DELETE FROM [dbo].[Creative] 
                WHERE  [AdId] IN (SELECT [AdID] 
                                   FROM   [dbo].[Pattern] 
                                   WHERE  mediastream = @MediastreamID) 

                -- Remove TV Ad's 
                DELETE FROM ad 
                WHERE  [AdID] IN (SELECT [AdID] 
                                 FROM   [dbo].[Pattern] 
                                 WHERE  mediastream = @MediastreamID) 

                -- Remove  TV Pattern Master Data 
                DELETE FROM [dbo].[Pattern] 
                WHERE  mediastream = @MediastreamID 

                -- Remove TV Occurrences 
                DELETE FROM [OccurrenceDetailTV] 

                -- Remove Query Details for TV 
                DELETE FROM [QueryDetail] 
                WHERE  [MediaStreamID] = 'TV' 

                --- Remove ingested TV pattern details 
                DELETE FROM [dbo].[PatternDetailTVStaging] 

                -- Remove Ingested TV Creative details  
                DELETE FROM [dbo].[CreativeDetailStagingTV] 

                -- Remove Ingested TV Creative master Records 
                DELETE FROM [CreativeStaging] 
                WHERE  [CreativeStagingID] IN (SELECT [CreativeStagingID] 
                                 FROM   [PatternStaging] where MediaStream = 144) 

                -- Remove Ingested Pattern Master Records 
                DELETE FROM [PatternStaging] where MediaStream = 144 

                -- Removes the Exception Records of TV 
                DELETE FROM [ExceptionDetail] 
                WHERE  mediastream = 'TV' 
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

          RAISERROR ('[sp_CleanupTV]: %d: %s',16,1,@ERROR,@MESSAGE,@LINENO ); 

          ROLLBACK TRANSACTION 
      END catch 
  END