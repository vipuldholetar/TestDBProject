-- ====================================================================================
-- Author		: Murali 
-- Create date	: 07/24/2015
-- Description	: Get City Name list in TV Work Queue
-- Updated By	: Karunakar on 14th Sep 2015
--=================================================================================
CREATE PROCEDURE [dbo].[sp_TelevisionWorkQueueLoadCityName]
AS
BEGIN
		SET NOCOUNT ON;
			  
			  BEGIN TRY
						SELECT  distinct([Market].[MarketID]), [Market].[Descrip] AS CityName 
					FROM 
					--[OccurrenceDetailTV] 
					--INNER JOIN 
					TVRecordingSchedule --ON [OccurrenceDetailTV].CaptureStationCode = TVRecordingSchedule.CaptureStationCode
					INNER JOIN 
					[TVStation] ON TVRecordingSchedule.[TVStationID] = [TVStation].[TVStationID] 
					INNER JOIN 
					[Market] ON [TVStation].[MarketID] = [Market].[MarketID]
					where DisplayInMediaStreams = 1
				END TRY

				BEGIN CATCH
					DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
					SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
					RAISERROR ('sp_TelevisionWorkQueueLoadCityName: %d: %s',16,1,@error,@message,@lineNo); 
					ROLLBACK TRANSACTION
				END CATCH
END