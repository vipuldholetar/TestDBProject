-- ===========================================================================================
-- Author: 
-- Create date: 09/04/2015
-- Description:	This stored procedure deals with Capture Code Translations for TV Ingestion
-- ===========================================================================================
CREATE PROCEDURE [dbo].[sp_TVIngestionCapturecodeTranslation_Old]
	@CaptureStationCode varchar(10),
	@AirDateTime datetime,
	@CaptureTime time,
	@MTStationId int output,
	@RecordingScheduleId int output
AS
BEGIN
	SET NOCOUNT ON;
	select 
		@MTStationId = [TVStationID], @RecordingScheduleId = [TVRecordingScheduleID]
	from 
		TVRecordingSchedule
	where
		CaptureStationCode = @CaptureStationCode and
		@AirDateTime between [EffectiveStartDT] and isnull([EffectiveEndDT],getdate()) and
		@CaptureTime BETWEEN cast([StartDT] as time) AND cast([EndDT] as time)
	
    SELECT @MTStationId, @RecordingScheduleId
END