
CREATE PROCEDURE [dbo].[Sp_CleanupCircular] 
AS 
  BEGIN 
      BEGIN try 
          BEGIN TRANSACTION 

          DECLARE @MediastreamID AS INT=0 

          SELECT @MediastreamID = configurationid 
          FROM   [Configuration] 
          WHERE  componentname = 'Media Stream' 
                 AND value = 'CIR' 

          IF @MediastreamID > 0 
            BEGIN 
                -- Removing the Pattern and Ad mapping  
                UPDATE [OccurrenceDetailCIR] 
                SET    [PatternID] = NULL, 
                       [AdID] = NULL 

                -- Remove Creative details for Circular  
                DELETE FROM [dbo].[creativedetailcir] 

                -- Remove Creative Master Records for Circular  
                DELETE FROM [dbo].[Creative] 
                WHERE  [AdId] IN (SELECT [AdID] 
                                   FROM   [dbo].[Pattern] 
                                   WHERE  mediastream = @MediastreamID 
                                          AND [AdID] IS NOT NULL) 

                -- Remove Circular  Ad's  
                DELETE FROM ad 
                WHERE  [AdID] IN (SELECT [AdID] 
                                 FROM   [dbo].[Pattern] 
                                 WHERE  mediastream = @MediastreamID) 

                -- Remove Pattern Master Data  
                DELETE FROM [dbo].[Pattern] 
                WHERE  mediastream = @MediastreamID 

                -- Remove Circular Occurrences  
                DELETE FROM [OccurrenceDetailCIR] 

                -- Remove Query Details for Circular  
                DELETE FROM [QueryDetail] 
                WHERE  [MediaStreamID] = 'CIR' 
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

          RAISERROR ('[sp_CleanupCircular]: %d: %s',16,1,@ERROR,@MESSAGE,@LINENO 
          ); 

          ROLLBACK TRANSACTION 
      END catch 
  END
