-- =========================================================================
-- Author: Nagarjuna
-- Create date: 09/04/2015
-- Description:	This stored procedure deals with AirDate & time Translations
-- =========================================================================
CREATE PROCEDURE [dbo].[sp_TVIngestionAirTimeTranslation]
	@MTStationId int,
	@AirDateTime datetime,
	@TranslatedAirDate datetime output
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY 
          BEGIN TRANSACTION 

			declare @HourOffSet int
			select @HourOffSet=0

			select 
				@HourOffSet = HoursOffset
			from 
				TVTimeZone
			where
				[MTStationID] = @MTStationId and
				@AirDateTime between [EffectiveStartDT] and isnull([EffectiveEndDT],getdate())
			
			SELECT @TranslatedAirDate = dateadd(HH,-1*@HourOffSet,@AirDateTime)

          COMMIT TRANSACTION 
      END TRY 

      BEGIN CATCH 
          DECLARE @Error   INT, 
                  @Message VARCHAR(4000), 
                  @LineNo  INT 

          SELECT @Error = Error_number(), 
                 @Message = Error_message(), 
                 @LineNo = Error_line() 

          RAISERROR ('sp_TVIngestionAirTimeTranslation: %d: %s',16,1,@Error,@Message,@LineNo); 

          ROLLBACK TRANSACTION 
      END CATCH; 	
END