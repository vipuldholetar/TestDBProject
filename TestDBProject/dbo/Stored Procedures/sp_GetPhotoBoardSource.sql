CREATE PROCEDURE [dbo].[sp_GetPhotoBoardSource]
(
@AdId as int,
@MediaType Varchar(100) = ''
)
AS
BEGIN

		SET NOCOUNT ON;
		BEGIN TRY									
		
		if @MediaType = 'Radio'
		begin
		
			SELECT  isnull(RCSRadioStation.ShortName,'') as  ShortName
			FROM	Ad
			JOIN	OccurrenceDetailRA
					ON 	Ad.PrimaryOccurrenceId = OccurrenceDetailRAID
			JOIN
					RCSRadioStation
					ON RCSRadioStation.RCSRadioStationID = OccurrenceDetailRA.RCSStationID
			WHERE	Ad.AdId = @AdId

		end


		END TRY

		BEGIN CATCH 
				DECLARE @error   INT,@message VARCHAR(4000), @lineNo  INT 
				SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				RAISERROR ('[sp_GetPhotoBoardSource]: %d: %s',16,1,@error,@message,@lineNo);
		END CATCH 
END