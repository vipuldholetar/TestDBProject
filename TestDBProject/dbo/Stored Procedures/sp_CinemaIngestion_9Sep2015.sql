-- =============================================



-- Author		: Imtiaz Khan

-- Create date	: 07/13/2015 

-- Description	: Procedure for Cinema Ingestion -- Inserting into tables OccurrenceDetailsCIN, PatternMasterStagingCIN, CINPatterns

-- Updated By	: Monika on 09/2/2015 

-- Execute		:[sp_CinemaIngestion] 



--===================================================



CREATE PROCEDURE [dbo].[sp_CinemaIngestion_9Sep2015] (@CinemaIngData  dbo.NCMBatchWiseData READONLY)

AS

BEGIN

	SET NOCOUNT ON;

	BEGIN TRY 

		DECLARE @Customer VARCHAR(200)

		DECLARE @StartDate DATETIME

		DECLARE @EndDate DATETIME

		DECLARE @Rating VARCHAR(200)

		DECLARE @Length INT

		DECLARE @AdName VARCHAR(200)

		DECLARE @Result VARCHAR(MAX)

		DECLARE @Count INT

		DECLARE @DateCount DATETIME

		DECLARE @Worktype as int

		DECLARE @DMANetwork as int



		BEGIN TRANSACTION



			SELECT @Worktype = Value FROM [Configuration] WHERE componentname='WorkType' and valuetitle='Ingestion'

			DECLARE @tempTable table

			(

				RowId int IDENTITY(1,1),

				PK_Id int

			)



			INSERT INTO @tempTable(PK_Id) SELECT PK_Id  FROM  @CinemaIngData



			DECLARE @TopCount INT ,@Counter INT

			SET @TopCount=1

			SELECT @Counter=count(RowId) FROM @tempTable



			WHILE (@Counter>0)

			BEGIN

				DECLARE @id  INT

				SELECT @id = PK_Id FROM @tempTable WHERE RowId=@TopCount

				SELECT  @Customer = Customer, @StartDate = StartDate, @EndDate = EndDate, @Rating = Rating, @Length = [Length], @AdName = AdName ,@DMANetwork=DMANetwork

				FROM @CinemaIngData WHERE PK_Id=@id

				SET @DateCount = @StartDate

					IF(@StartDate<>'' AND @EndDate<>'')

						BEGIN

							SET @Count = (DATEDIFF(day, @StartDate, @EndDate))+1

						END

				WHILE(@count<>0)

					BEGIN

							INSERT INTO [OccurrenceDetailCIN]([PatternID], [AdID], [MarketID], WorkType, [CreativeID], [AirDT], Customer,

													Rating, [Length], [CreatedDT], [ModifiedDT])

							VALUES (Null, Null, @DMANetwork, @Worktype, [dbo].fn_CINCreativeName(@AdName), @DateCount, @Customer, [dbo].fn_CINRatingString(@Rating),

								@Length, GetDate(), Null)

						SET @DateCount = @DateCount+1

						SET @count = @count-1

					END



                --UPDATE RAW DATA 

				UPDATE NCMRAWDATA

				SET INGESTIONSTATUS=1 WHERE [NCMRawDataID]=@id;

				select @Counter=@Counter-1

				select @TopCount=@TopCount+1



			END



		--Insert Into PatternMasterStgCIN



		INSERT INTO [PatternCINStaging]([CreativeMasterStagingID], [CreativeSignatureCODE], TotalQScore, ScoreQ, [LanguageID],

										IsQuery, IsException, CreateDTM, CreatedBy, ModifiedDTM, ModifiedBy)

		SELECT  Null, [dbo].fn_CINCreativeName(AdName), Null, Null, 1, 0, 0, GetDate(), 1, Null, Null 

							FROM @CinemaIngData   



		--Insert Into CINPatterns



		INSERT INTO [CINPattern]([CreativeID], [AirDT], [CustomerID], Rating, [Length], [CreatedDT], [ModifiedDT])

		SELECT [dbo].fn_CINCreativeName(AdName), StartDate, Null, [dbo].fn_CINRatingString(Rating), [Length], GetDate(), Null

				FROM @CinemaIngData



		COMMIT TRANSACTION

	END TRY

	BEGIN CATCH



		DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 

		SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 

		RAISERROR ('[sp_CinemaIngestion]: %d: %s',16,1,@error,@message,@lineNo);

		ROLLBACK TRANSACTION



	END CATCH



END