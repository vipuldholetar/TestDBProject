
--- Mobile 
-- =============================================   
-- Author:    Ganesh   
-- alter date: 07/12/2015   
-- Description:  Cleanup Mobile Records   
-- Execution :  Exec sp_CleanupMobile 
-- =============================================   
CREATE PROCEDURE [dbo].[sp_CleanupMobile] 
AS 
  BEGIN 
      BEGIN try 
          BEGIN TRANSACTION 

          DECLARE @MediastreamID AS INT=0 

          SELECT @MediastreamID = configurationid 
          FROM   [Configuration] 
          WHERE  componentname = 'Media Stream' 
                 AND value = 'MOB' 

          IF @MediastreamID > 0 
            BEGIN 
                UPDATE [OccurrenceDetailMOB] 
                SET    [PatternID] = NULL, 
                       [AdID] = NULL, 
                       [PatternStagingID] = NULL 

                -- Remove Creative details for Mobile 
                DELETE FROM [dbo].[creativedetailmob] 

                -- Remove Creative Master Records for Mobile 
                DELETE FROM [dbo].[Creative] 
                WHERE  [AdId] IN (SELECT [AdID] 
                                   FROM   [dbo].[Pattern] 
                                   WHERE  mediastream = @MediastreamID) 

                -- Remove Mobile Ad's 
                DELETE FROM ad 
                WHERE  [AdID] IN (SELECT [AdID] 
                                 FROM   [dbo].[Pattern] 
                                 WHERE  mediastream = @MediastreamID) 

                -- Remove Pattern Master Data 
                DELETE FROM [dbo].[Pattern] 
                WHERE  mediastream = @MediastreamID 

                --- Remove Occurrence details for MOB 
                DELETE FROM [OccurrenceDetailMOB] 

                -- Remove Query Details for Mobile 
                DELETE FROM [QueryDetail] 
                WHERE  [MediaStreamID] = 'MOB' 

                -- Remove Ingested Mobile Creative details   
                DELETE FROM [dbo].[creativedetailstagingmob] 

                -- Remove Ingested Mobile Creative master Records 
                PRINT( 'deleting creativemasterstg records' ) 

                DELETE FROM [CreativeStaging] 
                WHERE  [CreativeStagingID] IN (SELECT [CreativeStgID] 
                                 FROM   [PatternStaging] 
                                 WHERE  ( mediastream = CONVERT(VARCHAR(50), 
                                                        @MediastreamID) 
                                           OR mediastream = 'MOB' )) 

                -- Remove Ingested Pattern Master Records 
                DELETE FROM [PatternStaging] 
                WHERE  mediastream = CONVERT(VARCHAR(50), @MediastreamID) 

                --Removes Exception Records for Mobile 
                DELETE FROM [ExceptionDetail] 
                WHERE  mediastream = 'MOB' 
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

          RAISERROR ('[sp_CleanupMobile]: %d: %s',16,1,@ERROR,@MESSAGE,@LINENO ) 
          ; 

          ROLLBACK TRANSACTION 
      END catch 
  END 

SET ansi_nulls ON