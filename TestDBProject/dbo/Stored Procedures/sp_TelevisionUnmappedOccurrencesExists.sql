-- =============================================
-- Author:		Ashanie Cole
-- Create date:	October 2016
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_TelevisionUnmappedOccurrencesExists]
	@Adid as INT,
	@PRCode as VARCHAR(50)
AS
BEGIN
	   DECLARE @mediastream AS VARCHAR(50)

	   SELECT @mediastream = configurationid 
          FROM   [Configuration] 
          WHERE  systemname = 'ALL' 
                 AND componentname = 'media stream' 
                 AND valuetitle = 'Television' 

	  IF EXISTS( SELECT a.OccurrenceDetailTVID 
	   FROM OccurrenceDetailTV a, TVRecordingSchedule b, TVStation c
	   -- XXX is for TV
	   WHERE a.PRCODE = @PRCode
	   AND a.AdID IS NULL
	   AND b.TVRecordingScheduleID = a.TVRecordingScheduleID
	   AND c.TVStationID = b.TVStationID
	   AND a.OccurrenceDetailTVID NOT IN (
		  SELECT a.OccurrenceDetailTVID
		  FROM OccurrenceDetailTV a, TVMMPRCode b, TVRecordingSchedule c, TVStation d		-- XXX is for TV
		  WHERE b.OriginalPatternCode = @PRCode
		  AND c.TVRecordingScheduleID = a.TVRecordingScheduleID
		  AND d.TVStationID = c.TVStationID
		  AND b.ApprovedMarketID = d.MarketID
		  AND b.Status = 'RE'		-- Rejected for individual Market
		  AND a.PRCODE = b.OriginalPatternCode
		  AND a.FakePatternCODE IS NULL
		  AND (a.AirDT >= b.EffectiveStartDT OR b.EffectiveStartDT IS NULL)
		  AND (a.AirDT <= b.EffectiveEndDT OR b.EffectiveEndDT IS NULL) 
		  AND a.AdID IS NULL		-- not mapped
		  AND b.AdID = @Adid
		  AND b.MediaStream = @mediastream
	   )
	   )
	   BEGIN
		  SELECT '1' AS UnmappedOccurrencesExists
	   END
	   ELSE
	   BEGIN
		  SELECT '0' AS UnmappedOccurrencesExists
	   END
END