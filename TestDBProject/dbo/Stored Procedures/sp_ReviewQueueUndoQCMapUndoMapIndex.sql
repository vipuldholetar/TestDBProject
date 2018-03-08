
-- =================================================================================
-- Author			:	Arun Nair 
-- Create date		:	2nd September 2015
-- Description		:	ReviewQueueUndo QC Map, Undo the Map and Index
-- Update By		:	Ramesh Bangi for Online Display on 	09/25/2015	
--					:	Karunakar on 13th October 2015,Adding Mobile and Online Video Media Streams		
-- =================================================================================
CREATE PROCEDURE [dbo].[sp_ReviewQueueUndoQCMapUndoMapIndex] (
	@MediaStreamID AS INT
	,@PatternmasterId AS INT
	,@AdId AS INT
	,@OccurrenceId AS INT
	,@UserId AS INT
	,@DeleteOrphanAd AS INT = 0
	)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @PatternCount AS INT = 0
		DECLARE @ExistingAdId AS INT
		DECLARE @MediaStream AS NVARCHAR(max) = ''

		SELECT @ExistingAdId = AdId
		FROM Pattern
		WHERE [PatternID] = @PatternmasterId

		SELECT @PatternCount = count(*)
		FROM [Pattern]
		WHERE [AdID] = @ExistingAdId

		IF @PatternCount = 1 AND @DeleteOrphanAd = 0
		BEGIN
			SELECT 0 AS result
		END
		ELSE
		BEGIN
			SELECT @MediaStream = Value
			FROM [dbo].[Configuration]
			WHERE ConfigurationID = @MediaStreamID

			BEGIN TRANSACTION

			IF (@MediaStream = 'RAD')
			BEGIN
				UPDATE [dbo].[Pattern]
				SET [AdID] = @AdId
					,AuditBy = @UserId
					,AuditDate = getdate()
				WHERE [PatternID] = @PatternmasterId

				UPDATE [dbo].[OccurrenceDetailRA]
				SET [AdID] = @AdId
				WHERE [PatternID] = @PatternmasterId
			END

			IF (@MediaStream = 'TV')
			BEGIN
				UPDATE [dbo].[Pattern]
				SET [AdID] = @AdId
					,AuditBy = @UserId
					,AuditDate = getdate()
				WHERE [PatternID] = @PatternmasterId

				UPDATE [dbo].[OccurrenceDetailTV]
				SET [AdID] = @AdId
				WHERE [PatternID] = @PatternmasterId
			END

			IF (@MediaStream = 'OD')
			BEGIN
				UPDATE [dbo].[Pattern]
				SET [AdID] = @AdId
					,AuditBy = @UserId
					,AuditDate = getdate()
				WHERE [PatternID] = @PatternmasterId

				UPDATE [dbo].[OccurrenceDetailODR]
				SET [AdID] = @AdId
				WHERE [PatternID] = @PatternmasterId
			END

			IF (@MediaStream = 'CIN')
			BEGIN
				UPDATE [dbo].[Pattern]
				SET [AdID] = @AdId
					,AuditBy = @UserId
					,AuditDate = getdate()
				WHERE [PatternID] = @PatternmasterId

				UPDATE [dbo].[OccurrenceDetailCIN]
				SET [AdID] = @AdId
				WHERE [PatternID] = @PatternmasterId
			END

			IF (@MediaStream = 'OND')
			BEGIN
				UPDATE [dbo].[Pattern]
				SET [AdID] = @AdId
					,AuditBy = @UserId
					,AuditDate = getdate()
				WHERE [PatternID] = @PatternmasterId

				UPDATE [dbo].[OccurrenceDetailOND]
				SET [AdID] = @AdId
				WHERE [PatternID] = @PatternmasterId
			END

			IF (@MediaStream = 'ONV')
			BEGIN
				UPDATE [dbo].[Pattern]
				SET [AdID] = @AdId
					,AuditBy = @UserId
					,AuditDate = getdate()
				WHERE [PatternID] = @PatternmasterId

				UPDATE [dbo].[OccurrenceDetailONV]
				SET [AdID] = @AdId
				WHERE [PatternID] = @PatternmasterId
			END

			IF (@MediaStream = 'MOB')
			BEGIN
				UPDATE [dbo].[Pattern]
				SET [AdID] = @AdId
					,AuditBy = @UserId
					,AuditDate = getdate()
				WHERE [PatternID] = @PatternmasterId

				UPDATE [dbo].[OccurrenceDetailMOB]
				SET [AdID] = @AdId
				WHERE [PatternID] = @PatternmasterId
			END

			IF @PatternCount = 1 AND @DeleteOrphanAd = 1
			BEGIN
				UPDATE Ad SET Valid = 0 WHERE AdId = @ExistingAdId
			END

			SELECT 1 AS result
		END

		COMMIT TRANSACTION
	END TRY

	BEGIN CATCH
		DECLARE @error INT
			,@message VARCHAR(4000)
			,@lineNo INT

		SELECT @error = Error_number()
			,@message = Error_message()
			,@lineNo = Error_line()

		RAISERROR (
				'[sp_ReviewQueueUndoQCMapUndoMapIndex]: %d: %s'
				,16
				,1
				,@error
				,@message
				,@lineNo
				);

		ROLLBACK TRANSACTION
	END CATCH
END