
-- =============================================   
-- Author:    Ganesh   
-- alter date: 07/12/2015   
-- Description:  Cleanup Radio Records   
-- Execution :  Exec sp_CleanupRadio 
-- =============================================   
CREATE PROCEDURE [dbo].[sp_CleanupRadio] 
AS 
  BEGIN 
      BEGIN try 
          BEGIN TRANSACTION 

          DECLARE @MediastreamID AS INT=0 

          SELECT @MediastreamID = configurationid 
          FROM   [Configuration] 
          WHERE  componentname = 'Media Stream' 
                 AND value = 'RAD' 

          IF @MediastreamID > 0 
            BEGIN 
                -- Removing the Pattern and Ad mapping 
                UPDATE [OccurrenceDetailRA] 
                SET    [PatternID] = NULL, 
                       [AdID] = NULL 

                -- Remove Pattern Details 
                DELETE FROM [dbo].[patterndetailra] 

                -- Remove Creative details for Radio 
                DELETE FROM [dbo].[CreativeDetailRA] 

                -- Remove Creative Master Records for Radio 
                DELETE FROM [dbo].[Creative] 
                WHERE  [AdId] IN (SELECT [AdID] 
                                   FROM   [dbo].[Pattern] 
                                   WHERE  mediastream = @MediastreamID) 

                -- Remove Radio Ad's 
                DELETE FROM [dbo].[ad] 
                WHERE  [AdID] IN (SELECT [AdID] 
                                 FROM   [dbo].[Pattern] 
                                 WHERE  mediastream = @MediastreamID) 

                -- Remove Pattern Master Data 
                DELETE FROM [dbo].[Pattern] 
                WHERE  mediastream = @MediastreamID 

                -- Remove Radio Occurrences 
                DELETE FROM [dbo].[OccurrenceDetailRA] 

                -- Remove Query Details for Radio 
                DELETE FROM [dbo].[QueryDetail] 
                WHERE  [MediaStreamID] = 'RAD' 

                -- Remove ingested Radio pattern details 
                DELETE FROM [dbo].[PatternDetailRAStaging] 

                -- Remove Ingested Radio Creative details  
                DELETE FROM [dbo].[CreativeDetailStagingRA] 

                -- Remove Ingested Radio Creative master Records 
                DELETE FROM [dbo].[CreativeStaging] 
                WHERE  [CreativeStagingID] IN (SELECT [CreativeStgID] 
                                 FROM   [PatternStaging] 
                                 WHERE  mediastream = 'RAD') 

                -- Remove Ingested Pattern Master Records 
                DELETE FROM [dbo].[PatternStaging] 
                WHERE  mediastream = 'RAD' 

                --Deletes Exception Records of Radio  
                DELETE FROM [dbo].[ExceptionDetail] 
                WHERE  mediastream = 'RAD' 
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

          RAISERROR ('[sp_CleanupRadio]: %d: %s',16,1,@ERROR,@MESSAGE,@LINENO); 

          ROLLBACK TRANSACTION 
      END catch 
  END