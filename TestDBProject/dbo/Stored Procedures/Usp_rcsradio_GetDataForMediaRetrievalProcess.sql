-- =============================================       

-- Author:    Govardhan.R       

-- Create date: 04/06/2015       

-- Description:  Get Data for RCS media process       

-- Query : exec Usp_rcsradio_GetDataForMediaRetrievalProcess     

-- =============================================       

CREATE PROCEDURE [dbo].[Usp_rcsradio_GetDataForMediaRetrievalProcess]

AS 

  BEGIN 

      SET nocount ON; 



      BEGIN try 

          BEGIN TRANSACTION 



          SELECT Filter.[RCSCreativeID],Filter.RCSAcidID,Filter.[RCSStationID],Filter.[AirStartDT],Filter.[AirEndDT],FILTER.[OccurrenceDetailRAID],PatternMasterStagingID FROM 

		  (

		  select row_number() over(partition by MAP.[RCSCreativeID] ORDER BY [AirDT])[SlNo],MAP.[RCSCreativeID],MAP.RCSAcidID,OCR.[RCSStationID],

		  OCR.[AirStartDT],OCR.[AirEndDT],OCR.[OccurrenceDetailRAID],pm.PatternMasterStagingID

		  from [PATTERNMASTERSTAGING] PM inner join 

          [patterndetailrastaging] PD on PD.PatternMasterStagingID=PM.PatternMasterStagingID

		  inner join [RCSCreative] RC on RC.RCSCreativeID=PD.RCSCreativeID

		  inner join RCSACIDTORCSCREATIVEIDMAP MAP ON MAP.[RCSCreativeID]=RC.RCSCreativeID

		  INNER JOIN [OccurrenceDetailRA] OCR ON OCR.[RCSAcIdID]=MAP.RCSAcidID

		-- WHERE PM.CreativeStagingID IS NULL

		  ) as Filter where Filter.SlNo=1



          COMMIT TRANSACTION 

      END try 



      BEGIN catch 

          DECLARE @error   INT, 

                  @message VARCHAR(4000), 

                  @lineNo  INT 



          SELECT @error = Error_number(), 

                 @message = Error_message(), 

                 @lineNo = Error_line() 



          RAISERROR ('Usp_rcsradio_GetDataForMediaRetrievalProcess: %d: %s',16,1,@error, 

                     @message, 

                     @lineNo); 



          ROLLBACK TRANSACTION 

      END catch; 

  END;