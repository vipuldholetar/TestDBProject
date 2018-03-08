-- =============================================
-- Author:		Ashanie Cole
-- Create date:	December 2016
-- Description:	get Ad details for PR JPEG form
-- =============================================
CREATE PROCEDURE sp_TelevisionGetAdDetailsByPRCode
	@PRCode as varchar(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
	   SELECT AdID, PRCODE, OccurrenceDetailTVID,M.MarketId, M.Descrip AS Market,
	   AdLength as [Length]
	   ,  (SELECT TOP 1 Market.Descrip FROM    [OccurrenceDetailTV] 
		  INNER JOIN  TVRecordingSchedule ON [OccurrenceDetailTV].[TVRecordingScheduleID] = TVRecordingSchedule.[TVRecordingScheduleID]
		  INNER JOIN  [TVStation] ON [TVRecordingSchedule].[TVStationID] = [TVStation].[TVStationID]
		  INNER JOIN [Market] ON [TVStation].[MarketID] = [Market].[MarketID]
		  WHERE [OccurrenceDetailTV].[PRCODE]=@PRCode
		  ORDER BY [OccurrenceDetailTV].CreatedDT ASC) AS FirstMarket
	   FROM  [OccurrenceDetailTV] 
		  INNER JOIN  TVRecordingSchedule ON [OccurrenceDetailTV].[TVRecordingScheduleID] = TVRecordingSchedule.[TVRecordingScheduleID]
		  INNER JOIN  [TVStation] ON [TVRecordingSchedule].[TVStationID] = [TVStation].[TVStationID]
		  INNER JOIN [Market] M ON [TVStation].[MarketID] = M.[MarketID]
	   WHERE PRCODE = @PRCode
    END  TRY
    BEGIN CATCH
		  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
		  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
		  RAISERROR ('[sp_GetAdDetailsPRJPEG]: %d: %s',16,1,@error,@message,@lineNo);
    END CATCH
END