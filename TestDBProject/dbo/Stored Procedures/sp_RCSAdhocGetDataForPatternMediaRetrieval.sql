-- =============================================        

-- Author:    KARUNAKAR       

-- Create date: 9th December 2015        

-- Description:  Get PatternmasterId from Exception Details for RCS media process        

-- Query : exec sp_RCSAdhocGetDataForPatternMediaRetrieval     

-- =============================================        

CREATE PROCEDURE [dbo].[sp_RCSAdhocGetDataForPatternMediaRetrieval] 

AS 

  BEGIN 

      SET nocount ON; 



      BEGIN try 

          BEGIN TRANSACTION 	  



		  DECLARE @MediaStream AS varchar(250);
		  select @MediaStream = Value from [Configuration] where ValueTitle='Radio'
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

                  WHERE  PM.[PatternStagingID] In(select [PatternMasterStagingID] from [dbo].[ExceptionDetail] where MediaStream = @MediaStream and ltrim(rtrim(ExceptionStatus)) ='Alternate Creative Requested') ) AS Filter 

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



          RAISERROR ('sp_RCSAdhocGetDataForPatternMediaRetrieval: %d: %s',16,1 

                     , 

                     @Error,@Message, 

                     @LineNo); 



          ROLLBACK TRANSACTION 

      END catch; 

  END;