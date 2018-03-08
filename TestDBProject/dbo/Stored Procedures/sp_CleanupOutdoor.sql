
-- =============================================   
-- Author:    Ganesh   
-- alter date: 07/12/2015   
-- Description:  Cleanup Outdoor Records   
-- Execution :  Exec sp_CleanupOutdoor 
-- =============================================   
CREATE PROCEDURE [dbo].[sp_CleanupOutdoor] 
AS 
  BEGIN 
      BEGIN try 
          BEGIN TRANSACTION 

          DECLARE @MediastreamID AS INT=0 

          SELECT @MediastreamID = configurationid 
          FROM   [Configuration] 
          WHERE  componentname = 'Media Stream' 
                 AND value = 'OD' 

          IF @MediastreamID > 0 
            BEGIN 
                -- Removing the Pattern and Ad mapping 
                UPDATE [OccurrenceDetailODR] 
                SET    [PatternID] = NULL, 
                       [AdID] = NULL 

                -- Remove Creative Master Records for OutDoor 
                DELETE FROM [dbo].[Creative] 
                WHERE  [AdId] IN (SELECT [AdID] 
                                   FROM   [dbo].[Pattern] 
                                   WHERE  mediastream = @MediastreamID) 

                -- Remove OutDoor Ad's 
                DELETE FROM ad 
                WHERE  [AdID] IN (SELECT [AdID] 
                                 FROM   [dbo].[Pattern] 
                                 WHERE  mediastream = @MediastreamID) 

                -- Remove Pattern Master Data 
                DELETE FROM [dbo].[Pattern] 
                WHERE  mediastream = @MediastreamID 

                -- Remove OutDoor Occurrences 
                DELETE FROM [OccurrenceDetailODR] 

				-- Remove Creative Details Outdoor
				Delete from creativedetailodr
                -- Remove Query Details for OutDoor 
                DELETE FROM [QueryDetail] 
                WHERE  [MediaStreamID] = 'OD' 

                -- Remove Ingested Outdoor Creative details  
                DELETE FROM [dbo].[CreativeDetailStagingODR] 

                -- Remove Ingested OutDoor Creative master Records 
                DELETE FROM [CreativeStaging] 
                WHERE  [CreativeStagingID] IN (SELECT [CreativeStgID] 
                                 FROM   [PatternODRStaging]) 

                -- Remove Ingested Pattern Master Records 
                DELETE FROM [PatternODRStaging] 

                -- Remove Exception Records of OutDoor 
                DELETE FROM [ExceptionDetail] 
                WHERE  mediastream = 'OD' 
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

          RAISERROR ('[sp_CleanupOutdoor]: %d: %s',16,1,@ERROR,@MESSAGE,@LINENO 
          ); 

          ROLLBACK TRANSACTION 
      END catch 
  END