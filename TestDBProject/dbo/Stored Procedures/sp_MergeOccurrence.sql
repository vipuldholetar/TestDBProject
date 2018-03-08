CREATE PROCEDURE [dbo].[sp_MergeOccurrence]
		@SurvivingAdID INT,
		@NonSurvivingAdID INT,
		@MediaType VARCHAR(20),
		@Occurrences VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;
		BEGIN TRY
		BEGIN TRANSACTION 

		Declare @IsSplitOccurrence as Bit
		Declare @NoTakeReason as int
		Declare @MediaStreamVal AS NVARCHAR(50)

		Declare @PrimaryOccrnceID as Bigint
		Declare @FirstRunDate as nvarchar(50)
		Declare @LastRunDate as nvarchar(50)
		Declare @FirstRunMarket as integer

		Select @NoTakeReason=ConfigurationID  from [Configuration]   where componentname='No Take Ad' and ValueTitle='Duplicate'


		IF @MediaType = 'Email'
		BEGIN

		UPDATE OccurrenceDetailEM
		SET AdID = @SurvivingAdID
		WHERE OccurrenceDetailEMID IN (Select Id from [dbo].[fn_CSVToTable](@Occurrences))

		UPDATE Pattern
		SET AdID = @SurvivingAdID
		FROM OccurrenceDetailEM a, Pattern b
		WHERE b.PatternID = a.PatternID
		AND a.OccurrenceDetailEMID IN (Select Id from [dbo].[fn_CSVToTable](@Occurrences))

		UPDATE Creative
		SET AdID = @SurvivingAdID
		FROM Creative a, OccurrenceDetailEM b, Pattern c
		WHERE (a.CreativeType = 'Original' or a.CreativeType is null)
		AND c.PatternID = b.PatternID
		AND a.PK_ID = c.CreativeID
		AND a.PrimaryIndicator = 0
		AND b.OccurrenceDetailEMID IN (Select Id from [dbo].[fn_CSVToTable](@Occurrences))

		UPDATE Creative
		SET AdID = @SurvivingAdID,
			PrimaryIndicator = 0
		FROM Creative a, OccurrenceDetailEM b, Pattern c
		WHERE (a.CreativeType = 'Original' or a.CreativeType is null)
		AND a.PrimaryIndicator = 1
		AND c.PatternID = b.PatternID
		AND a.PK_ID = c.CreativeID
		AND b.OccurrenceDetailEMID in (Select Id from [dbo].[fn_CSVToTable](@Occurrences))

		IF not exists (select 1 from OccurrenceDetailEM where OccurrenceDetailEM.AdId = @NonSurvivingAdID)
		BEGIN
			UPDATE Ad
			SET NoTakeAdReason = @NoTakeReason
			WHERE AdID = @NonSurvivingAdID
		END
		ELSE 
		BEGIN
			IF Not Exists(Select 1 from [OccurrenceDetailEM] ocr,Ad a  where a.[PrimaryOccurrenceID]=ocr.[OccurrenceDetailEMID] and a.[AdID]=ocr.[AdID] and a.[AdID]=@NonSurvivingAdid)
			BEGIN
				UPDATE Ad
				SET PrimaryOccurrenceID = (Select Min(b.[OccurrenceDetailWEBID])  FROM Ad a, [OccurrenceDetailWEB] b where b.AdID = a.AdID)
				FROM Ad a, OccurrenceDetailEM b
				WHERE a.AdID = @NonSurvivingAdID
				AND b.AdID = a.AdID
				AND b.NoTakeReason IS NULL
			END

			IF Not Exists(Select 1 from ad a inner join [OccurrenceDetailEM] ocr on a.[PrimaryOccurrenceID]=ocr.[OccurrenceDetailEMID] inner join [Pattern] p on ocr.[PatternID]=p.[PatternID]
				inner join [Creative] c on p.[CreativeID]=c.PK_Id
																where a.[AdID]=@NonSurvivingAdid and c.PrimaryIndicator=1)
			BEGIN
				UPDATE Creative
				SET PrimaryIndicator = 1
				FROM Creative a, OccurrenceDetailEM b,      
					 Pattern c,Ad ad
				WHERE b.OccurrenceDetailEMID = ad.PrimaryOccurrenceID
				AND c.PatternID = b.PatternID
				AND a.PK_Id = c.CreativeID
				AND a.PK_Id = @NonSurvivingAdId
			END
		END

		Select @FirstRunDate=[OccurrenceDetailEM].[AdDT],@FirstRunMarket=[OccurrenceDetailEM].[MarketID] 
		from [OccurrenceDetailEM] inner join ad on [OccurrenceDetailEM].[AdID]=ad.[AdID]
		where [OccurrenceDetailEM].[AdID]=@SurvivingAdid 
		group by [OccurrenceDetailEM].[AdDT],[OccurrenceDetailEM].[MarketID],Ad.FirstRunDate
		Having Min([OccurrenceDetailEM].[AdDT])<=(Ad.FirstRunDate)

		Select @LastRunDate=[OccurrenceDetailEM].[AdDT]
		from [OccurrenceDetailEM] inner join ad on [OccurrenceDetailEM].[AdID]=ad.[AdID]
		where [OccurrenceDetailEM].[AdID]=@SurvivingAdid 
		group by [OccurrenceDetailEM].[AdDT],Ad.FirstRunDate
		having Max([OccurrenceDetailEM].[AdDT])>=(Ad.FirstRunDate)

		Update Ad  Set Ad.FirstRunDate=@FirstRunDate,ad.[FirstRunMarketID]=@FirstRunMarket,Ad.LastRunDate=@LastRunDate where Ad.[AdID]=@SurvivingAdid
				
		END
		
		
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