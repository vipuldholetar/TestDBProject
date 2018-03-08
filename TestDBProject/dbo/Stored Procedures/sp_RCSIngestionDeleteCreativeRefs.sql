
-- =============================================       
-- Author:    Govardhan.R       
-- Create date: 04/07/2015       
-- Description:  Process RCS Ingestion Process       
-- Query : exec sp_RCSIngestionDeleteCreativeRefs '1'   
-- Update 2017-03-14 - ADavey:  modified delete logic to set Occurrence [Deleted] flag to 1;  removed incorrect updates to RCSCreative and Map tables.    
-- =============================================       
CREATE PROCEDURE [sp_RCSIngestionDeleteCreativeRefs] 
@CreativeId  AS VARCHAR(255), 
@SeqId AS BIGINT 
AS 
  BEGIN 
      SET nocount ON; 

      BEGIN try 
          BEGIN TRANSACTION 

          DECLARE @OccrncCount AS INT 

          SELECT @OccrncCount = Count(*) 
          FROM   [OccurrenceDetailRA] 
          WHERE  exists (select 1 
		                 from RCSRawData 
						 where RCSRawDataID = @SeqId
						 and RCSRawData.StationID = [OccurrenceDetailRA].RCSStationID 
						 and RCSRawData.StartDT = [OccurrenceDetailRA].AirStartDT
						 and RCSRawData.EndDT = [OccurrenceDetailRA].AirEndDT
						 ) 

          IF( @OccrncCount = 1 ) 
            BEGIN 
                --            --Delete from CreativeDetailsRAStg table.  
                --            DELETE FROM creativedetailsraStg   
                --            WHERE  creativemasterStgId IN (          
                --select distinct CMS.creativemasterStgId FROM   Occrncdetailsra OCRA  
                --inner join RCSAcIdToRCSCreativeIdMap ACMap on ACMap.rcsacIdId=OCRA.rcsacIdId  
                --inner join creativemasterStg CMS on CMS.OccrncId=OCRA.OccrncId 
                --where ACMap.rcscreativeId = @CreativeId AND ACMap.IsDeleted = 0  
                --                                  )  
                --Delete from CreativeMasterStg table.  
				/*
                DELETE FROM [CreativeStaging] 
                WHERE  [OccurrenceID] IN (SELECT DISTINCT [OccurrenceDetailRAID] 
                                        FROM   [OccurrenceDetailRA] OCRA 
                       INNER JOIN RCSAcIdToRCSCreativeIdMap 
                                  ACMap 
                               ON ACMap.[RCSAcIdToRCSCreativeIdMapID] = 
                                  OCRA.[RCSAcIdID] 
                                        WHERE  ACMap.[RCSCreativeID] = @CreativeId 
                                               AND ACMap.[Deleted] = 0) 
                */

                --PENDING WAITING FOR SHEREBOYA  
                --Delete rcord from PATTERNMASTERStg table.   
                DELETE FROM [PatternStaging] 
                WHERE  [PatternStagingID] IN (SELECT [PatternStgID] 
                                                  FROM   [PatternDetailRAStaging] 
                                                  WHERE 
                       [RCSCreativeID] = @CreativeId) 
            --Delete from PatternDetailRAStg Table  
            --DELETE FROM  PatternDetailRAStg   
            --WHERE  RCScreativeId = @CreativeId  
            END 

          --Soft delete the record in OccrncDETAILSRA table.   
          UPDATE [OccurrenceDetailRA] 
          SET    [PatternID] = NULL, 
                 [AdID] = NULL ,
				 [Deleted] = 1
          WHERE  exists (select 1 
		                 from RCSRawData 
						 where RCSRawDataID = @SeqId
						 and RCSRawData.StationID = [OccurrenceDetailRA].RCSStationID 
						 and RCSRawData.StartDT = [OccurrenceDetailRA].AirStartDT
						 and RCSRawData.EndDT = [OccurrenceDetailRA].AirEndDT
						 ) 

          /*
		  --Soft delete the record in RCSAcIdToRCSCreativeIdMap table.   
		  UPDATE RCSAcIdToRCSCreativeIdMap 
          SET    [Deleted] = 1 
          WHERE  [RCSCreativeID] = @CreativeId 
                 AND [Deleted] = 0 

          --Soft delete the record in RCSCReatives table.   
          UPDATE [RCSCreative] 
          SET    [Deleted] = 1 
          WHERE  [RCSCreativeID] = @CreativeId 
                 AND [Deleted] = 0 
		  */

          ---uPDATE STATUS  
          UPDATE RCSRawData 
          SET    IngestionStatus = 1 
          WHERE  [SeqID] = @SeqId 

          COMMIT TRANSACTION 
      END try 

      BEGIN catch 
          DECLARE @Error   INT, 
                  @Message VARCHAR(4000), 
                  @LineNo  INT 

          SELECT @Error = Error_number(), 
                 @Message = Error_message(), 
                 @LineNo = Error_line() 

          RAISERROR ('sp_RCSIngestionDeleteCreativeRefs: %d: %s', 
                     16, 
                     1, 
                     @Error,@Message, 
                     @LineNo); 

          ROLLBACK TRANSACTION 
      END catch; 
  END;