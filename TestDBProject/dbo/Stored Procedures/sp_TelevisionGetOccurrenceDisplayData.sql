
-- ============================================================
-- Author:		Murali Jaganathan
-- Create date: 7/17/2015
-- Description:	 Get Occurrence
-- Updated By :
-- Execution  : sp_TelevisionGetOccurrenceDisplayData 10002 
--=============================================================

CREATE PROCEDURE  [dbo].[sp_TelevisionGetOccurrenceDisplayData]
(
@OccurrenceId AS INTEGER
)
AS
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRY
			
			SELECT  [OccurrenceDetailTV].[OccurrenceDetailTVID] As OccurrenceId,[AdLength],CONVERT(NVARCHAR(10),[OccurrenceDetailTV].[AirDT], 101) AS AirDate, convert(char(5), [OccurrenceDetailTV].AirTime, 108) As AirTime,[Market].[Descrip],
		    [TVNetwork].[NetworkShortName],[TVStation].[StationFullName] AS TVStation,'' As Program
		    FROM            [OccurrenceDetailTV] 
			INNER JOIN		TVRecordingSchedule ON [OccurrenceDetailTV].[TVRecordingScheduleID] = TVRecordingSchedule.[TVRecordingScheduleID] 
			INNER JOIN		[TVStation] ON TVRecordingSchedule.[TVStationID] = [TVStation].[TVStationID]
			INNER JOIN		[Market] on Market.[MarketID] = [TVStation].[MarketID]
			INNER JOIN		[TVNetwork] on TVNetwork.TVNetworkID = [TVStation].[NetworkID]
			 Where [OccurrenceDetailTV].[OccurrenceDetailTVID] = @OccurrenceId
		END TRY
		BEGIN CATCH 
        DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT
			SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line()
            RAISERROR ('sp_TelevisionGetOccurrenceDisplayData: %d: %s',16,1,@error,@message,@lineNo);
		END CATCH 
END