-- ===========================================================================================================================
-- Author				: KARUNAKAR.P
-- Create Date			: 12/14/2015
-- Description			: This stored procedure is used to Updating Patternmasterstg Id Exception Status into 'Alternate Creative Requested'
-- Execution Process	: [dbo].[sp_ExceptionMakePatternAlternateCreative] 
-- Updated By			: 
-- ============================================================================================================================

CREATE PROCEDURE [dbo].[sp_ExceptionMakePatternAlternateCreative]  
(
@PatternmasterstdId AS BIGINT,
@MediaStreamId AS NVARCHAR(50)
)
AS
BEGIN
        Declare @MediaStreamValue As NVARCHAR(50)
		Select @MediaStreamValue = Value From [Configuration] Where SystemName = 'All' And ComponentName = 'Media Stream' And ValueTitle = @MediaStreamId
		BEGIN TRY
		BEGIN TRANSACTION

				IF(@MediaStreamValue='TV' or @MediaStreamValue = 'CIN' or @MediaStreamValue='RAD' or @MediaStreamValue='OND' Or  @MediaStreamValue='ONV' Or @MediaStreamValue='MOB' or @MediaStreamValue='CIR')
				BEGIN
					--On Exception Status Change in  to "Alternate Creative"
					UPDATE [dbo].[ExceptionDetail] set ExceptionStatus  = 'Alternate Creative Requested' 
					where [PatternMasterStagingID] = @PatternmasterstdId and MediaStream=@MediaStreamValue
				END		
		COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
					DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
					SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
					RAISERROR ('[sp_ExceptionMakePatternAlternateCreative]: %d: %s',16,1,@error,@message,@lineNo); 
					ROLLBACK TRANSACTION
		END CATCH

END