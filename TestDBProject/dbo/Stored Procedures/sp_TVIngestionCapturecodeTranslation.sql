-- ===========================================================================================
-- Author: Nagarjuna
-- Create date: 09/04/2015
-- Description:	This stored procedure deals with Capture Code Translations for TV Ingestion
-- ===========================================================================================
CREATE PROCEDURE [dbo].[sp_TVIngestionCapturecodeTranslation]
	@CaptureStationCode varchar(10),
	@AirDateTime datetime,
	@CaptureTime time,
	@MTStationId int output,
	@RecordingScheduleId int output
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY 
            select 
				@MTStationId = [TVStationID], @RecordingScheduleId = [TVRecordingScheduleID]
			from 
				TVRecordingSchedule 
			where
				CaptureStationCode = @CaptureStationCode and
				@AirDateTime between [EffectiveStartDT] and isnull([EffectiveEndDT],getdate()) and
				@CaptureTime BETWEEN cast([StartDT] as time) AND cast([EndDT] as time) and
				charindex(case datepart(WeekDay,@AirDateTime) when 1 then 'U' when 2 then 'M' when 3 then 'T' when 4 then 'W' when 5 then 'H' when 6 then 'F' when 7 then 'S' end, WeekDays) > 0
			
			SELECT @MTStationId, @RecordingScheduleId
      END TRY 

      BEGIN CATCH 
          DECLARE @Error   INT, 
                  @Message VARCHAR(4000), 
                  @LineNo  INT 

          SELECT @Error = Error_number(), 
                 @Message = Error_message(), 
                 @LineNo = Error_line() 

          RAISERROR ('sp_TVIngestionCapturecodeTranslation: %d: %s',16,1,@Error,@Message,@LineNo); 

      END CATCH; 
END