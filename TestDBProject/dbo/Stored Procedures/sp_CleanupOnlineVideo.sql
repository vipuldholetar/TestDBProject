
CREATE PROCEDURE [dbo].[sp_CleanupOnlineVideo] 
AS 
  BEGIN 
      BEGIN try 
          BEGIN TRANSACTION 

          DECLARE @MediastreamID AS INT=0 

          SELECT @MediastreamID = configurationid 
          FROM   [Configuration] 
          WHERE  componentname = 'Media Stream' 
                 AND value = 'ONV' 

          IF @MediastreamID > 0 
            BEGIN 
                UPDATE [OccurrenceDetailONV] 
                SET    [PatternID] = NULL, 
                       [AdID] = NULL, 
                       [PatternStagingID] = NULL 

                DELETE FROM [dbo].[creativedetailonv] 
                -- Remove Creative details for Online Video 
                -- Remove Creative Master Records for Online Video 
                DELETE FROM [dbo].[Creative] 
                WHERE  [AdId] IN (SELECT [AdID] 
                                   FROM   [dbo].[Pattern] 
                                   WHERE  mediastream = @MediastreamID) 

                -- Remove Online Video Ad's 
                DELETE FROM ad 
                WHERE  [AdID] IN (SELECT [AdID] 
                                 FROM   [dbo].[Pattern] 
                                 WHERE  mediastream = @MediastreamID) 

                -- Remove Pattern Master Data 
                DELETE FROM [dbo].[Pattern] 
                WHERE  mediastream = @MediastreamID 

                -- Remove Online Video Occurrences       
                DELETE FROM [OccurrenceDetailONV] 

                -- Remove Query Details for Online Video 
                DELETE FROM [QueryDetail] 
                WHERE  [MediaStreamID] = 'ONV' 

                -- Remove Ingested Online Video Creative details 
                DELETE FROM [dbo].[creativedetailstagingonv] 

                -- Remove Ingested Online Video Creative master Records 
                DELETE FROM [CreativeStaging] 
                WHERE  [CreativeStagingID] IN (SELECT [CreativeStgID] 
                                 FROM   [PatternStaging] 
                                 WHERE  mediastream = 'ONV' 
                                         OR mediastream = CONVERT(VARCHAR(50), 
                                                          @MediastreamID)) 

                -- Remove Ingested Pattern Master Records of Online Video 
                DELETE FROM [PatternStaging] 
                WHERE  mediastream = CONVERT(VARCHAR(50), @MediastreamID) 

                ---Deletes the Exception Details of OnlineVideo 
                DELETE FROM [ExceptionDetail] 
                WHERE  mediastream = 'ONV' 
                        OR mediastream = CONVERT(VARCHAR(50), @MediastreamID) 
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

          RAISERROR ('[sp_CleanupOnlineVideo]: %d: %s',16,1,@ERROR,@MESSAGE, 
                     @LINENO ); 

          ROLLBACK TRANSACTION 
      END catch 
  END