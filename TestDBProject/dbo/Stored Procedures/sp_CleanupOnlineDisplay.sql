
-- =============================================   
-- Author:    Ganesh   
-- alter date: 07/12/2015   
-- Description:  Cleanup OnlineDisplay Records   
-- Execution :  Exec sp_CleanupOnlineDisplay 
-- =============================================  
CREATE PROCEDURE [dbo].[sp_CleanupOnlineDisplay] 
AS 
  BEGIN 
      BEGIN try 
          BEGIN TRANSACTION 

          DECLARE @MediastreamID AS INT=0 

          SELECT @MediastreamID = configurationid 
          FROM   [Configuration] 
          WHERE  componentname = 'Media Stream' 
                 AND value = 'OND' 

          IF @MediastreamID > 0 
            BEGIN 
                UPDATE [OccurrenceDetailOND] 
                SET    [PatternID] = NULL, 
                       [AdID] = NULL, 
                       [PatternStagingID] = NULL 
            END 

          BEGIN 
              -- Remove Online Display Occurrences 
              DELETE FROM [OccurrenceDetailOND] 

              --Removes CreativeDetails For Online Display 
              DELETE FROM [dbo].[creativedetailond] 

              -- Remove Creative Master Records for Online Display 
              DELETE FROM [dbo].[Creative] 
              WHERE  [AdId] IN (SELECT [AdID] 
                                 FROM   [dbo].[Pattern] 
                                 WHERE  mediastream = @MediastreamID) 

              -- Remove Online Display Ad's 
              DELETE FROM ad 
              WHERE  [AdID] IN (SELECT [AdID] 
                               FROM   [dbo].[Pattern] 
                               WHERE  mediastream = @MediastreamID) 

              -- Remove Pattern Master Data 
              DELETE FROM [dbo].[Pattern] 
              WHERE  mediastream = @MediastreamID 

              -- Remove Query Details for Online Display 
              DELETE FROM [QueryDetail] 
              WHERE  [MediaStreamID] = 'OND' 

              -- Remove Ingested Online Display Creative details  
              DELETE FROM [dbo].[creativedetailstagingond] 

              -- Remove Ingested Online Display Creative master Records 
              DELETE FROM [CreativeStaging] 
              WHERE  [CreativeStagingID] IN (SELECT [CreativeStgID] 
                               FROM   [PatternStaging] 
                               WHERE  mediastream = CONVERT(VARCHAR(50), 
                                                    @MediastreamID) 
                                       OR mediastream = 'OND') 

              -- Remove Ingested Pattern Master Records of Online Display 
              DELETE FROM [PatternStaging] 
              WHERE  mediastream = CONVERT(VARCHAR(50), @MediastreamID) 
                      OR mediastream = 'OND' 

              --Remove Exception records of Online Display 
              DELETE FROM [ExceptionDetail] 
              WHERE  mediastream = 'OND' 
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

          RAISERROR ('[sp_CleanupOnlineDisplay]: %d: %s',16,1,@ERROR,@MESSAGE, 
                     @LINENO 
          ); 

          ROLLBACK TRANSACTION 
      END catch 
  END