-- =========================================================================
-- Author: 
-- Create date: 09/04/2015
-- Description:	This stored procedure deals with AirDate & time Translations
-- =========================================================================
CREATE PROCEDURE [dbo].[sp_TVIngestionAirTimeTranslation_Old]
	@MTStationId int,
	@AirDateTime datetime,
	@TranslatedAirDate datetime output
AS
BEGIN
	SET NOCOUNT ON;
	
	declare @HourOffSet int
	select @HourOffSet=0

	select 
		@TranslatedAirDate = HoursOffset
	from 
		TVTimeZone
	where
		[MTStationID] = @MTStationId and
		@AirDateTime between [EffectiveStartDT] and isnull([EffectiveEndDT],getdate())
	
    SELECT @TranslatedAirDate = dateadd(HH,-1*@HourOffSet,@AirDateTime)
END
