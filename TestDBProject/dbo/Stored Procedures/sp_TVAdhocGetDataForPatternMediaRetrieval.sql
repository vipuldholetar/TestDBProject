-- =============================================        
-- Author			:	KARUNAKAR       
-- Create date		:	16th December 2015        
-- Description		:	Get PatternmasterId from Exception Details for RCS media process        
-- Query			:	exec sp_TVAdhocGetDataForPatternMediaRetrieval     
-- =============================================        

CREATE PROCEDURE [dbo].[sp_TVAdhocGetDataForPatternMediaRetrieval] 

AS 

  BEGIN 

      SET nocount ON; 

      BEGIN try 
          BEGIN TRANSACTION 	  

		  DECLARE @MediaStream AS varchar(250);
		  select @MediaStream = Value from [Configuration] where ValueTitle='Television'
          SELECT  Filter.OriginalPRCode, 
                 Filter.Stationcode, 
                 Filter.AirDate, 
                 Filter.AirTime, 
                 Filter.UserID,
				 Filter.CaptureStationCode,
				 Filter.PatternMasterStagingID
		FROM
		(SELECT Row_number() 
				OVER( 
					partition BY P.OriginalPRCode 
					ORDER BY OCR.[AirDT]
					)[SlNo],
		P.OriginalPRCode,SM.StationShortName As Stationcode,
		CONVERT(NVARCHAR(10),OCR.[AirDT], 101) as AirDate,
		convert(char(8), OCR.AirTime, 108) As AirTime,
		SM.[CreatedByID] As UserID,
		OCR.CaptureStationCode,
		PM.[PatternStagingID] aS  PatternMasterStagingID
		FROM   [PatternStaging] PM
		INNER JOIN [OccurrenceDetailTV] OCR ON PM.[CreativeSignature]=OCR.[PRCODE]
		INNER JOIN  TVRecordingSchedule RS ON OCR.[TVRecordingScheduleID] = RS.[TVRecordingScheduleID]
		INNER JOIN  [TVStation] SM ON RS.[TVStationID] = SM.[TVStationID]
		INNER JOIN  [TVPattern] P ON P.[TVPatternCODE] = PM.[CreativeSignature]
		WHERE PM.[PatternStagingID] In (select [PatternMasterStagingID] from [dbo].[ExceptionDetail] where MediaStream = @MediaStream
		and ltrim(rtrim(ExceptionStatus)) ='Alternate Creative Requested')) aS Filter

		WHERE  Filter.slno = 1  
		order by PatternMasterStagingID
        COMMIT TRANSACTION 

      END try 
      BEGIN catch 
          DECLARE @Error   INT,@Message VARCHAR(4000),@LineNo  INT 
          SELECT @Error = Error_number(),@Message = Error_message(),@LineNo = Error_line() 
          RAISERROR ('sp_TVAdhocGetDataForPatternMediaRetrieval: %d: %s',16,1,@Error,@Message,@LineNo); 
          ROLLBACK TRANSACTION 
      END catch; 

  END;