
-- =============================================   
-- Author:    Ganesh   
-- alter date: 07/12/2015   
-- Description:  Cleanup Cinema Records   
-- Execution :  Exec sp_CleanupCinema 
-- =============================================   
CREATE PROCEDURE [dbo].[sp_CleanupCinema] 
AS 
  BEGIN 
      BEGIN try 
          BEGIN TRANSACTION 

          DECLARE @MediastreamID AS INT=0 

          SELECT @MediastreamID = configurationid 
          FROM   [Configuration] 
          WHERE  componentname = 'Media Stream' 
                 AND value = 'CIN' 

          IF @MediastreamID > 0 
            BEGIN 
                -- Removing the Pattern and Ad mapping 
                UPDATE [OccurrenceDetailCIN] 
                SET    [PatternID] = NULL, 
                       [AdID] = NULL 

                -- Delete Cinema Occurrences 
                DELETE FROM [dbo].[creativedetailcin] 

                -- Remove Creative Master Records for Radio 
                DELETE FROM [dbo].[Creative] 
                WHERE  [AdId] IN (SELECT [AdID] 
                                   FROM   [dbo].[Pattern] 
                                   WHERE  mediastream = @MediastreamID) 

                -- Remove Cinema Ad's 
                DELETE FROM ad 
                WHERE  [AdID] IN (SELECT [AdID] 
                                 FROM   [dbo].[Pattern] 
                                 WHERE  mediastream = @MediastreamID) 

                -- Remove Pattern Master Data 
                DELETE FROM [dbo].[Pattern] 
                WHERE  mediastream = @MediastreamID 

                -- Remove Cinema Occurrences 
                DELETE FROM [OccurrenceDetailCIN] 

                -- Remove Query Details for Cinema 
                DELETE FROM [QueryDetail] 
                WHERE  [MediaStreamID] = 'CIN' 

                -- Remove Ingested Cinema Creative details  
                DELETE FROM [dbo].[CreativeDetailStagingCIN] 

                -- Remove Ingested Cinema Creative master Records 
                DELETE FROM [CreativeStaging] 
                WHERE  [CreativeStagingID] IN (SELECT [CreativeStagingID] 
                                 FROM   [dbo].[PatternStaging]) 

                -- Remove Ingested Pattern Master Records 
                DELETE FROM [dbo].[PatternStaging] 

                --Removes the Exception Records of Cinema 
                DELETE FROM [dbo].[ExceptionDetail] 
                WHERE  mediastream = 'CIN' 
                        OR mediastream = '146' 
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

          RAISERROR ('[sp_CleanupCinema]: %d: %s',16,1,@ERROR,@MESSAGE,@LINENO ) 
          ; 

          ROLLBACK TRANSACTION 
      END catch 
  END