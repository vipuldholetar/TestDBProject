
-- =============================================        
-- Author:    Govardhan.R        
-- Create date: 04/06/2015        
-- Description:  Get Data for RCS media process        
-- Query : exec sp_RCSGetDataForMediaRetrievalProcess      
-- =============================================        
CREATE PROCEDURE [dbo].[sp_RCSGetDataForMediaRetrievalProcess] 
AS 
  BEGIN 
      SET nocount ON; 

      BEGIN try 
          BEGIN TRANSACTION 	  
          SELECT  Filter.[RCSCreativeID] [RCSCreativeID], 
                 Filter.[RCSAcIdToRCSCreativeIdMapID] [RCSAcidID], 
                 Filter.[RCSStationID] [RCSStationID], 
                 Filter.[AirStartDT], 
                 Filter.[AirEndDT],
				 Filter.[OccurrenceDetailRAID] [OccurrenceID],
				 PatternMasterStagingID
          FROM   (SELECT Row_number() 
                           OVER( 
                             partition BY MAP.[RCSCreativeID] 
                             ORDER BY [AirDT])[SlNo], 
                         MAP.[RCSCreativeID], 
                         MAP.[RCSAcIdToRCSCreativeIdMapID], 
                         OCR.[RCSStationID], 
                         OCR.[AirStartDT], 
                         OCR.[AirEndDT],
						 OCR.[OccurrenceDetailRAID],
						 PM.[PatternStagingID] [PatternMasterStagingID]
                  FROM   [PatternStaging] PM 
                         INNER JOIN [PatternDetailRAStaging] PD 
                                 ON 
                         PD.[PatternStgID] = PM.[PatternStagingID] 
                         INNER JOIN [RCSCreative] RC 
                                 ON RC.[RCSCreativeID] = PD.[RCSCreativeID] 
                         INNER JOIN RCSAcIdToRCSCreativeIdMap MAP 
                                 ON MAP.[RCSCreativeID] = RC.[RCSCreativeID] 
                         INNER JOIN [OccurrenceDetailRA] OCR 
                                 ON OCR.[RCSAcIdID] = MAP.[RCSAcIdToRCSCreativeIdMapID] 
                  WHERE  PM.[CreativeStgID] IS NULL) AS Filter 
          WHERE  Filter.slno = 1  
		  order by PatternMasterStagingID

          COMMIT TRANSACTION 
      END try 

      BEGIN catch 
          DECLARE @Error   INT, 
                  @Message VARCHAR(4000), 
                  @LineNo  INT 

          SELECT @Error = Error_number(), 
                 @Message = Error_message(), 
                 @LineNo = Error_line() 

          RAISERROR ('sp_RCSGetDataForMediaRetrievalProcess: %d: %s',16,1 
                     , 
                     @Error,@Message, 
                     @LineNo); 

          ROLLBACK TRANSACTION 
      END catch; 
  END;