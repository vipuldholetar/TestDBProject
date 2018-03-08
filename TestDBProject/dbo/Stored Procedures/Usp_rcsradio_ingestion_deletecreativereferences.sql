-- =============================================      
-- Author:    Govardhan.R      
-- Create date: 04/07/2015      
-- Description:  Process RCS Ingestion Process      
-- Query : exec Usp_rcsradio_ingestion_DeleteCreativeReferences '1'      
-- =============================================      
CREATE PROCEDURE [dbo].[Usp_rcsradio_ingestion_deletecreativereferences] 
@CREATIVEID  AS VARCHAR(255), 
@SEQUENCE_ID AS BIGINT 
AS 
  BEGIN 
      SET nocount ON; 

      BEGIN try 
          BEGIN TRANSACTION 

          DECLARE @OccuranceCnt AS INT 

          SELECT @OccuranceCnt = Count(*) 
          FROM   [OccurrenceDetailRA] 
          WHERE  [RCSAcIdID] IN (SELECT [RCSAcIdID] 
                               FROM   rcsacidtorcscreativeidmap 
                               WHERE  [RCSCreativeID] = @CREATIVEID 
                                      AND [Deleted] = 0) 

          IF( @OccuranceCnt = 1 ) 
            BEGIN 
                --            --Delete from CreativeDetailsRAStaging table. 
                --            DELETE FROM creativedetailsrastaging  
                --            WHERE  CreativeStagingID IN (         
                --select distinct CMS.CreativeStagingID FROM   occurrencedetailsra OCRA 
                --inner join rcsacidtorcscreativeidmap ACMap on ACMap.rcsacidid=OCRA.rcsacidid 
                --inner join creativemasterstaging CMS on CMS.occurrenceid=OCRA.occurrenceid 
                --where ACMap.rcscreativeid = @CREATIVEID AND ACMap.isdeleted = 0 
                --                                  ) 
                --Delete from CreativeMasterStaging table. 
                DELETE FROM creativemasterstaging 
                WHERE  occurrenceid IN (SELECT DISTINCT [OccurrenceDetailRAID] 
                                        FROM   [OccurrenceDetailRA] OCRA 
                       INNER JOIN rcsacidtorcscreativeidmap 
                                  ACMap 
                               ON 
                       ACMap.rcsacidid = OCRA.[RCSAcIdID] 
                                        WHERE  ACMap.[RCSCreativeID] = @CREATIVEID 
                                               AND ACMap.[Deleted] = 0) 

                --PENDING WAITING FOR SHEREBOYA 
                --Delete rcord from PATTERNMASTERSTAGING table.  
                DELETE FROM patternmasterstaging 
                WHERE  patternmasterstagingid IN (SELECT patternmasterstagingid 
                                                  FROM   patterndetailrastaging 
                                                  WHERE 
                       rcscreativeid = @CREATIVEID) 
            --Delete from PatternDetailRAStaging Table 
            --DELETE FROM  PatternDetailRAStaging  
            --WHERE  RCScreativeid = @CREATIVEID 
            END 

          --Soft delete the record in OCCURRENCEDETAILSRA table.  
          UPDATE [OccurrenceDetailRA] 
          SET    [PatternID] = NULL, 
                 [AdID] = NULL 
          WHERE  [RCSAcIdID] IN (SELECT [RCSAcIdID] 
                               FROM   rcsacidtorcscreativeidmap 
                               WHERE  [RCSCreativeID] = @CREATIVEID 
                                      AND [Deleted] = 0) 

          --Soft delete the record in RCSACIDTORCSCREATIVEIDMAP table.  
          UPDATE rcsacidtorcscreativeidmap 
          SET    [Deleted] = 1 
          WHERE  [RCSCreativeID] = @CREATIVEID 
                 AND [Deleted] = 0 

          --Soft delete the record in RCSCReatives table.  
          UPDATE [RCSCreative] 
          SET    [Deleted] = 1 
          WHERE  rcscreativeid = @CREATIVEID 
                 AND [Deleted] = 0 

          ---uPDATE STATUS 
          UPDATE rcsrawdata 
          SET    ingestionstatus = 1 
          WHERE  SeqID = @SEQUENCE_ID 

          COMMIT TRANSACTION 
      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('Usp_rcsradio_ingestion_DeleteCreativeReferences: %d: %s', 
                     16, 
                     1, 
                     @error,@message, 
                     @lineNo); 

          ROLLBACK TRANSACTION 
      END catch; 
  END;