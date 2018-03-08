-- =============================================
-- Author:		Lisa East
-- Create date:	November 27,2017
-- Description:	get a list of occurrence for selected PRCODE for occurrence Form
-- =============================================
CREATE PROCEDURE [dbo].[sp_TelevisionGetOccurrenceListByPRCode]
	@PRCode as varchar(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
		SELECT o.OccurrenceDetailTVID as OccurrenceID, m.Descrip as Market, s.StationShortName as Station, n.NetworkShortName as NetWork, o.AirDT as AirDate, o.AirTime as AirTime, p.ProgramName as ProgramName
		FROM OccurrenceDetailTV o 
		join TVStation s on o.StationID = s.TVStationID
		left join TVNetwork n on s.NetworkID = n.TVNetworkID
		join Market m on s.MarketID = m.MarketID
		left join TVProgram p on p.TVProgramID = o.TVProgramID
		WHERE PRCODE = @PRCode
		and isnull(o.Deleted,0) = 0
		and InputFileName is not null
		ORDER BY station asc, AirDT desc, AirTime desc
    END  TRY
    BEGIN CATCH
		  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
		  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
		  RAISERROR ('[sp_TelevisionGetOccurrenceListByPRCode]: %d: %s',16,1,@error,@message,@lineNo);
    END CATCH
END