CREATE PROCEDURE [dbo].[sp_MergeAd]
		 @SurvivingAdID INT,
		 @NonSurvivingAdID INT,
		 @MediaType VARCHAR(20),
		 @CreativeType VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;
		BEGIN TRY
		BEGIN TRANSACTION 

		IF @CreativeType = ''
		BEGIN
			SET @CreativeType = NULL
		END

		IF @MediaType = 'Email'
		BEGIN
			UPDATE OccurrenceDetailEM
			SET AdID = @SurvivingAdID
			WHERE AdID = @NonSurvivingAdID
		END
		ELSE
		BEGIN
			UPDATE OccurrenceDetailRA
			SET AdID = @SurvivingAdID
			WHERE AdID = @NonSurvivingAdID
		END

		UPDATE Pattern
		SET AdID = @SurvivingAdID
		WHERE AdID = @NonSurvivingAdID

		UPDATE Creative
		SET AdID = @SurvivingAdID
		WHERE AdID = @NonSurvivingAdID
		AND PrimaryIndicator = 0

		UPDATE Creative
		SET AdID = @SurvivingAdID,
			PrimaryIndicator = 0
		WHERE AdID = @NonSurvivingAdID
		AND PrimaryIndicator = 1
		AND CreativeType = @CreativeType

		UPDATE Ad
		SET NoTakeAdReason = 3278
		WHERE AdID = @NonSurvivingAdID

		UPDATE Ad
		SET RecutAdID = @SurvivingAdID
		WHERE RecutAdID = @NonSurvivingAdID
		
		COMMIT TRANSACTION

		SELECT '1'
								
		END TRY
		BEGIN CATCH
		   DECLARE @ERROR   INT, 
                   @MESSAGE VARCHAR(4000), 
                   @LINENO  INT 

          SELECT @ERROR = Error_number(),@MESSAGE = Error_message(),@LINENO = Error_line() 
          RAISERROR ('[sp_MergeAd]: %d: %s',16,1,@ERROR,@MESSAGE,@LINENO); 
		  ROLLBACK TRANSACTION
		END CATCH
END