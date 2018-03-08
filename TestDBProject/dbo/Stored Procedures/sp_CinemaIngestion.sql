-- =============================================



-- Author		: Imtiaz Khan

-- Create date	: 07/13/2015 

-- Description	: Procedure for Cinema Ingestion -- Inserting into tables OccurrenceDetailsCIN, PatternMasterStagingCIN, Patterns

-- Updated By	: Monika on 09/2/2015 

-- Execute		:[sp_CinemaIngestion] 



--===================================================



CREATE PROCEDURE [dbo].[sp_CinemaIngestion] (@CinemaIngData  dbo.NCMBatchWiseData READONLY)

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

		DECLARE @Worktype AS INT

		DECLARE @DMANetwork AS VARCHAR(MAX)

		DECLARE @DMANetworkId AS INT

		DECLARE @FK_PatternMasterId AS INT

		DECLARE @FK_AdID AS INT



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

				SELECT  @Customer = Customer, @StartDate = StartDate, @EndDate = EndDate, @Rating = REPLACE ( Rating , ';' , ','), @Length = [Length], @AdName = AdName ,@DMANetwork=DMANetwork

				FROM @CinemaIngData WHERE PK_Id=@id

				SET @DMANetworkId = (SELECT [MarketID] FROM [Market] WHERE [CTLegacyLMKTCODE] = @DMANetwork)
				IF EXISTS(SELECT [PatternID] FROM [OccurrenceDetailCIN] WHERE [CreativeID]=@AdName AND [PatternID] IS NOT NULL AND [AdID] IS NOT NULL)
					BEGIN

					SELECT Top 1 @FK_PatternMasterId = [PatternID], @FK_AdID = [AdID]  FROM [OccurrenceDetailCIN] 
					WHERE [CreativeID]=@AdName AND [PatternID] IS NOT NULL AND [AdID] IS NOT NULL

				END			

				SET @DateCount = @StartDate

					IF(@StartDate<>'' AND @EndDate<>'')

						BEGIN

							SET @Count = (DATEDIFF(day, @StartDate, @EndDate))+1

						END

				WHILE(@count<>0)

					BEGIN

					

					INSERT INTO [OccurrenceDetailCIN]([PatternID], [AdID], [MarketID], WorkType, [CreativeID], [AirDT], Customer,

													Rating, [Length], [CreatedDT], [ModifiedDT])

							VALUES (@FK_PatternMasterId, @FK_AdID, @DMANetworkId, @Worktype, @AdName, @DateCount, @Customer, @Rating,

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

		INSERT INTO [PatternCINStg]( [CreativeSignature],[CreativeStagingID], TotalQScore, ScoreQ, [LanguageID],

											IsQuery, IsException, CreateDTM, CreatedBy, ModifiedDTM, ModifiedBy)

		SELECT DISTINCT AdName,Null,  Null, Null, 1, 0, 0, GetDate(), 1, Null, Null 

				FROM @CinemaIngData WHERE AdName NOT IN(SELECT DISTINCT([CreativeSignature]) FROM [PatternCINStg]) 


		--Insert Into Patterns



		

		

	-----------------------
		DECLARE @temp table

			(			
			CreativeId varchar(200), 
			AirDate datetime, 
			CustomerId int, 
			Rating varchar(200), 
			Length int, 
			CreateDTM datetime, 
			ModifyDTM datetime	
			)

			Insert into @temp (CreativeId, AirDate, CustomerId, Rating, Length, CreateDTM, ModifyDTM)
			SELECT DISTINCT AdName, StartDate, Null, Rating, [Length], GetDate(), Null
				FROM @CinemaIngData  WHERE AdName NOT IN(SELECT DISTINCT([CreativeID]) FROM [Pattern]) 

			INSERT INTO [Pattern]([CreativeID])--, [AirDT], [CustomerID], Rating, [Length], [CreatedDT], [ModifiedDT])
			select distinct CreativeId--, AirDate, CustomerId, Rating, Length, CreateDTM, ModifyDTM 
			from @temp as A where A.AirDate = (Select Min(AirDate) 
			from @temp where CreativeId=A.CreativeId) and A.Rating = (Select Top 1 Rating
			from @temp where CreativeId=A.CreativeId) and A.Length = (Select Top 1 Length
			from @temp where CreativeId=A.CreativeId)	

		COMMIT TRANSACTION

	END TRY

	BEGIN CATCH



		DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 

		SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 

		RAISERROR ('[sp_CinemaIngestion]: %d: %s',16,1,@error,@message,@lineNo);

		ROLLBACK TRANSACTION



	END CATCH



END