

-- =============================================     

-- Author:    Nagarjuna     

-- Create date: 07/17/2015     

-- Description:  This procedure is used to ingests the TV Ingestion raw pattern and occurrence data

-- Query : exec sp_TVIngestionForAdAndOccrncData_Test1

-- =============================================    

CREATE PROCEDURE [dbo].[sp_TVIngestionForAdAndOccrncData_Test1]

AS 

  BEGIN 

      SET nocount ON;

      BEGIN try 

	  BEGIN TRANSACTION 



	  --Table variable to hold TV Occurrence data.

		DECLARE @RawOccrncTVPlaylist TABLE

		(

		  [RowId] [INT] IDENTITY(1,1) NOT NULL,

		  [PK_Id] [bigint],

		  [PatternCode] [varchar](200),

		  [InputFileName] [varchar](200),

		  [CaptureStationCode] [varchar](200),

		  [AirDateTime] [datetime],

		  [CaptureTime] [time](7),

		  [Length] [int],

		  [CreateDTM] [datetime],

		  [IngestionDTM] [datetime],

		  [IngestionStatus] [varchar](200)

		);


		--Asit
		CREATE TABLE #TempRawOccrncTVPlaylist 

		(

		  [RowId] [INT] IDENTITY(1,1) NOT NULL,

		  [PK_Id] [bigint],

		  [PatternCode] [varchar](200),

		  [InputFileName] [varchar](200),

		  [CaptureStationCode] [varchar](200),

		  [AirDateTime] [datetime],

		  [CaptureTime] [time](7),

		  [Length] [int],

		  [CreateDTM] [datetime],

		  [IngestionDTM] [datetime],

		  [IngestionStatus] [varchar](200)

		);



		DECLARE @PatternMasterStgTV TABLE

		(

		  [RowId] [INT] IDENTITY(1,1) NOT NULL,

		  [PK_Id] [bigint],

		  [FK_CreativeSignature] [varchar](200)		 

		);



		DECLARE @TVPatterns TABLE

		(

		  [RowId] [INT] IDENTITY(1,1) NOT NULL,

		  [PK_PRCode] VARCHAR(200),

		  [OriginalPRCode] [varchar](200)		 

		);


		--Asit
		DECLARE @DistinctFileNameRawOccrncTVPlaylist TABLE

		(

		  [RowId] [INT] IDENTITY(1,1) NOT NULL,

		  [InputFileName] VARCHAR(200)	 

		);



		DECLARE @RowCount        INT, 

                @TotalRows       INT,

				@PatternRowCount INT,

				@TotalPatternRows INT,

				@RawOccrncAirDate	 DATETIME,				

				@PatternCode VARCHAR(200),

				@RawOccrncCaptureStationCode VARCHAR(200),

				@CaptureTime TIME,

				@TVRecordingScheduleId INT,

				@MTStationId INT,

				@HoursOffSet INT,

				@EthnicGroupId INT,

				@FakeEthnicPatternCode VARCHAR(200),

				@FakeEthnicPRCode VARCHAR(200),

				@FakeMMPatternCode VARCHAR(200),

				@FinalPRCode  VARCHAR(200),

				@ApprovedForAllMarkets BIT,

				@MarketId INT,

				@NewFakePatternCode VARCHAR(200),

				@SourceFileName VARCHAR(200),

				@Priority INT,

				@CSCTrans BIT,

				@ADTTrans BIT,

				@EPRCTrans BIT,

				@MMPRCTrans BIT,

				@JPEGPath varchar(200),

				@MediaFilePath varchar(200),

				@ExistingEthnicPRCode varchar(200),

				@ExistingMMPRCode varchar(200),

				@PatternMasterId INT,

				@AdId INT,

				@FK_PRCode varchar(200),

				@TotalCountRawTVPlaylist INT,

				@InsertCountOccrncDetailsTV INT,

			    @InputFileName VARCHAR(200),

				@TotalRowsTempTable INT,	--Asit

				@RowCountTempRawOccrncTVPlaylist INT



		SELECT @RowCount = 1, 

               @TotalRows = 0,

			   @CSCTrans = 0,

			   @ADTTrans = 0,

			   @EPRCTrans = 0,

			   @MMPRCTrans = 0,

			   @PatternRowCount = 1,

			   @TotalPatternRows = 0,

			   @JPEGPath = '',

			   @MediaFilePath = '',

			   @FinalPRCode = '',

			   @TotalRowsTempTable = 0,	--Asit

			   @RowCountTempRawOccrncTVPlaylist = 1



		--Insert TV Occurrence data to 
		
		INSERT INTO @RawOccrncTVPlaylist

		(

		[PK_Id],

		[InputFileName],

		[CaptureStationCode],

		[AirDateTime],

		[CaptureTime],

		[Length],

		[PatternCode],

		[CreateDTM],

		[IngestionDTM] 

		)

		SELECT DISTINCT 

		TV.[RawTVPlaylistID],

		TV.[InputFileName],

		TV.[CaptureStationCODE],

		TV.[AirDateTime],

		TV.[CaptureTime],

		TV.[Length],

		TV.[PatternCODE],

		TV.[CreatedDT],

		TV.[IngestionDT]

		FROM RawTVPlaylist TV

		INNER JOIN [RawTVNewAd] AD ON TV.[PatternCODE] = AD.[PatternCODE]
		--select * from @RawOccrncTVPlaylist
		--Asit
		INSERT INTO @DistinctFileNameRawOccrncTVPlaylist

		(
		
		[InputFileName]

		)

		SELECT DISTINCT 

		[InputFileName]

		FROM @RawOccrncTVPlaylist
		--select * from @DistinctFileNameRawOccrncTVPlaylist
		--ORDER BY CreateDTM DESC

		--INNER JOIN TVMMPRCodes MM ON MM.OriginalPatternCode = TV.PatternCode


		--Asit
		--SELECT @TotalRows = COUNT(*) FROM @RawOccrncTVPlaylist
		SELECT @TotalRows = COUNT(*) FROM @DistinctFileNameRawOccrncTVPlaylist
		--select @TotalRows
		--SET @TotalCountRawTVPlaylist = @TotalRows

		--set @TotalRows = 1450



		-- Looping 

		

		WHILE @TotalRows > 0

		BEGIN

			--Asit

			SET @InsertCountOccrncDetailsTV = 0

			SET @InputFileName = (SELECT InputFileName FROM @DistinctFileNameRawOccrncTVPlaylist WHERE RowId = @RowCountTempRawOccrncTVPlaylist)
			--select * from @RawOccrncTVPlaylist
			TRUNCATE TABLE #TempRawOccrncTVPlaylist

			INSERT INTO #TempRawOccrncTVPlaylist

			(

			[PK_Id],

			[InputFileName],

			[CaptureStationCode],

			[AirDateTime],

			[CaptureTime],

			[Length],

			[PatternCode],

			[CreateDTM],

			[IngestionDTM] 

			)

			SELECT 

			TV.[PK_Id],

			TV.[InputFileName],

			TV.[CaptureStationCode],

			TV.[AirDateTime],

			TV.[CaptureTime],

			TV.[Length],

			TV.[PatternCode],

			TV.[CreateDTM],

			TV.[IngestionDTM]

			FROM @RawOccrncTVPlaylist TV WHERE TV.[InputFileName] = @InputFileName		
				
			--select * from #TempRawOccrncTVPlaylist

			SELECT @TotalRowsTempTable = COUNT(*) FROM #TempRawOccrncTVPlaylist

			select @TotalRowsTempTable As TotalRowsTempTable

			SELECT @TotalRows = @TotalRows - 1

			WHILE @TotalRowsTempTable > 0

			BEGIN

			SELECT @TotalRowsTempTable = @TotalRowsTempTable - 1

			SELECT @FakeEthnicPRCode = ''

			SELECT @FakeEthnicPatternCode = ''

			--select @ExistingEthnicPRCode = 'False'

			--select @ExistingMMPRCode = 'False'



			--Fetch AirDateTime from playlist file

			SELECT @RawOccrncAirDate = [AirDateTime] FROM #TempRawOccrncTVPlaylist WHERE RowId = @RowCountTempRawOccrncTVPlaylist

			--Fetch PatternCode from playlist file

			SELECT @PatternCode = PatternCode FROM #TempRawOccrncTVPlaylist WHERE RowId = @RowCountTempRawOccrncTVPlaylist

			--Fetch capturestationcode from playlist file

			SELECT @RawOccrncCaptureStationCode = [CaptureStationCode] FROM #TempRawOccrncTVPlaylist WHERE RowId = @RowCountTempRawOccrncTVPlaylist

			--Fetch capture time from playlist file

			SELECT @CaptureTime = CaptureTime FROM #TempRawOccrncTVPlaylist WHERE RowId = @RowCountTempRawOccrncTVPlaylist

			--Fetch MTStationid from 

			SELECT @MTStationId = [TVStationID] FROM TVRecordingSchedule WHERE CaptureStationCode = @RawOccrncCaptureStationCode

			

			--Fetch MarketId from TVStationMaster table

			SELECT @MarketId = [MarketID] from [TVStation] where [TVStationID] = @MTStationId



			--Capture Station Code Translation

			--Validate CaptureStationCode

			IF (EXISTS(SELECT * FROM TVRecordingSchedule WHERE CaptureStationCode = @RawOccrncCaptureStationCode) )

			BEGIN 

				-- Validate Airdatetime

			    IF (EXISTS(SELECT * FROM TVRecordingSchedule WHERE CaptureStationCode = @RawOccrncCaptureStationCode and @RawOccrncAirDate BETWEEN [EffectiveStartDT] AND isnull([EffectiveEndDT],getdate())) )

				BEGIN 

					--Validate Capture time

				    IF (EXISTS(SELECT * FROM TVRecordingSchedule WHERE CaptureStationCode = @RawOccrncCaptureStationCode and @RawOccrncAirDate BETWEEN [EffectiveStartDT] AND isnull([EffectiveEndDT],getdate()) and @CaptureTime BETWEEN cast([StartDT] as time) AND cast(
[EndDT] as time)) )

					BEGIN 

						SET @CSCTrans = 1;

					    SELECT @TVRecordingScheduleId = [TVRecordingScheduleID] FROM TVRecordingSchedule WHERE CaptureStationCode = @RawOccrncCaptureStationCode and @RawOccrncAirDate BETWEEN [EffectiveStartDT] AND isnull([EffectiveEndDT],getdate()) and @CaptureTime BETWEEN cast([StartDT]
 as time) AND cast([EndDT] as time)

					END 

					ELSE 

					BEGIN 

					   SET @CSCTrans = 0;

					   UPDATE RawTVPlaylist SET IngestionStatus = 1 WHERE [PatternCODE] = @PatternCode

					   IF(EXISTS (SELECT * FROM [RawTVNewAd] WHERE [PatternCODE] = @PatternCode))

					   BEGIN

							UPDATE [RawTVNewAd] SET IngestionStatus = 1 WHERE [PatternCODE] = @PatternCode

					   END

					END 

				END 

				ELSE 

				BEGIN 

				   SET @CSCTrans = 0;

				   UPDATE RawTVPlaylist SET IngestionStatus = 1 WHERE [PatternCODE] = @PatternCode

				   IF(EXISTS (SELECT * FROM [RawTVNewAd] WHERE [PatternCODE] = @PatternCode))

				   BEGIN

						UPDATE [RawTVNewAd] SET IngestionStatus = 1 WHERE [PatternCODE] = @PatternCode

				   END

				END 

			END 

			ELSE 

			BEGIN 

			   SET @CSCTrans = 0;

			   UPDATE RawTVPlaylist SET IngestionStatus = 1 WHERE [PatternCODE] = @PatternCode

			   IF(EXISTS (SELECT * FROM [RawTVNewAd] WHERE [PatternCODE] = @PatternCode))

			   BEGIN

					UPDATE [RawTVNewAd] SET IngestionStatus = 1 WHERE [PatternCODE] = @PatternCode

			   END

			END 



			-- AirDateTime Translation

			-- Validate MTStationId in TVTimeZone table

			IF(@CSCTrans = 1)

			BEGIN

			IF (EXISTS(SELECT * FROM TVTimeZone WHERE [MTStationID] = @MTStationId ))

			BEGIN 

				-- Validate Airdate with TVTimeZone EffectiveStartDate and EffectiveEndDate

			    IF (EXISTS(SELECT * FROM TVTimeZone WHERE [MTStationID] = @MTStationId AND @RawOccrncAirDate BETWEEN [EffectiveStartDT] AND isnull([EffectiveEndDT],getdate())) )

				BEGIN 

					SET @ADTTrans = 1;

				    SELECT @HoursOffSet = HoursOffset FROM TVTimeZone WHERE [MTStationID] = @MTStationId

					SET @RawOccrncAirDate = DATEADD(minute, -@HoursOffSet, @RawOccrncAirDate)

				END 

			END 

			ELSE 

			BEGIN 

			   SET @ADTTrans = 0;

			   UPDATE RawTVPlaylist SET IngestionStatus = 1 WHERE [PatternCODE] = @PatternCode

			   IF(EXISTS (SELECT * FROM [RawTVNewAd] WHERE [PatternCODE] = @PatternCode))

			   BEGIN

					UPDATE [RawTVNewAd] SET IngestionStatus = 1 WHERE [PatternCODE] = @PatternCode

			   END

			END 

			END



			-- Ethnic PR Code Translation

			IF(@ADTTrans = 1)

			BEGIN

			IF (EXISTS(SELECT * FROM [TVStation] WHERE [TVStationID] = @MTStationId) )

			BEGIN		

				--Fetch EthnicGroupId from TVStationMaster

				SELECT @EthnicGroupId = EthnicGroupId FROM [TVStation] WHERE [TVStationID] = @MTStationId

					

				IF(@EthnicGroupId != 1)

				BEGIN

				

				IF (EXISTS(SELECT * FROM [TVEthnicPRCode] WHERE [EthnicGroupID] = @EthnicGroupId AND OriginalPRCode = @PatternCode) )

				BEGIN

					SET @EPRCTrans = 1

					SELECT @FakeEthnicPatternCode = [TVEthnicPRCodeID] FROM [TVEthnicPRCode] WHERE [EthnicGroupID] = @EthnicGroupId AND OriginalPRCode = @PatternCode 

					--SELECT @ExistingEthnicPRCode = 	@FakeEthnicPatternCode	    

				END 

				ELSE 

				BEGIN 

					--Fetch the latest ethnic PR code from TVEthnicPRCodes table

					SELECT @FakeEthnicPRCode = Max(SUBString([TVEthnicPRCodeID], 1,8)) from [TVEthnicPRCode]

					SET @FakeEthnicPRCode = CONCAT(CONVERT(INT,@FakeEthnicPRCode) + 1,'.ETH')

				 --  INSERT INTO TVEthnicPRCodes

				 --  (

					--PK_Id,

					--FK_EthnicGroupId,

					--OriginalPRCode,

					--CreateDTM

				 --  )

				 --  VALUES

				 --  (

				 --   @FakeEthnicPRCode,

					--@EthnicGroupId,

					--@PatternCode,

					--GETDATE()

				 --  )

				   SET @FakeEthnicPatternCode = @FakeEthnicPRCode

				   SET @EPRCTrans = 1			  

				END

				END

				ELSE

				BEGIN



				 -- MMPRCode translation

				   IF (EXISTS(SELECT * FROM [TVMMPRCode] WHERE OriginalPatternCode = @PatternCode) )

				   BEGIN 

				       IF (EXISTS(SELECT * FROM [TVMMPRCode] WHERE OriginalPatternCode = @PatternCode AND @RawOccrncAirDate BETWEEN [EffectiveStartDT] AND isnull([EffectiveEndDT],getdate())) )

					   BEGIN

						   SELECT @ApprovedForAllMarkets = ApprovedForAllMarkets FROM [TVMMPRCode] WHERE OriginalPatternCode = @PatternCode

						   IF (@ApprovedForAllMarkets = 0)

						   BEGIN 

							    IF (EXISTS(SELECT * FROM [TVMMPRCode] WHERE [ApprovedMarketID] = @MarketId) )

								BEGIN 

									SET @MMPRCTrans = 1

								    SELECT @FakeMMPatternCode = [TVMMPRCodeCODE] FROM [TVMMPRCode] WHERE [ApprovedMarketID] = @MarketId																	

								END

								ELSE 

								BEGIN 

								   SELECT @NewFakePatternCode = MAX([TVMMPRCodeCODE]) from [TVMMPRCode] where [TVMMPRCodeCODE] not like '%[^0-9]%' 

								   SET @NewFakePatternCode = CONVERT(INT, @NewFakePatternCode)+1



								 --  INSERT INTO TVMMPRCodes

								 --  (

								 --   PK_FakePatternCode,

									--FK_ApprovedMarket,

									--OriginalPatternCode,

									--ApprovedForAllMarkets,

									--EffectiveStartDate,									

									--CreateDTM,

									--CreatedBy,

									--ModifiedDTM

								 --  )

								 --  VALUES

								 --  (

								 --  @NewFakePatternCode,

								 --  @MarketId,

								 --  @PatternCode,

								 --  0,

								 --  GETDATE(),

								 --  GETDATE(),

								 --  1,

								 --  GETDATE()

								 --  )								   

								   SET  @FakeMMPatternCode = @NewFakePatternCode

								   SET @MMPRCTrans = 1

								END 

						   END 

						   ELSE 

						   BEGIN 

						      SELECT @FakeMMPatternCode = [TVMMPRCodeCODE] FROM [TVMMPRCode] WHERE OriginalPatternCode = @PatternCode

							  --SELECT @ExistingMMPRCode = 	@FakeMMPatternCode	

							  SET @MMPRCTrans = 1

						   END 

					   END 

					   ELSE 

					   BEGIN 

							SET @MMPRCTrans = 0							

							UPDATE RawTVPlaylist SET IngestionStatus = 1 WHERE [PatternCODE] = @PatternCode

							IF(EXISTS (SELECT * FROM [RawTVNewAd] WHERE [PatternCODE] = @PatternCode))

							BEGIN

							UPDATE [RawTVNewAd] SET IngestionStatus = 1 WHERE [PatternCODE] = @PatternCode

							END

					   END 

				   END 

				   ELSE 

				   BEGIN

						SET @MMPRCTrans = 0

						UPDATE RawTVPlaylist SET IngestionStatus = 1 WHERE [PatternCODE] = @PatternCode

						IF(EXISTS (SELECT * FROM [RawTVNewAd] WHERE [PatternCODE] = @PatternCode))

						BEGIN

						UPDATE [RawTVNewAd] SET IngestionStatus = 1 WHERE [PatternCODE] = @PatternCode

						END

				   END 

				END				

			END 

			ELSE 

			BEGIN 

				SET @EPRCTrans = 0

				UPDATE RawTVPlaylist SET IngestionStatus = 1 WHERE [PatternCODE] = @PatternCode

				IF(EXISTS (SELECT * FROM [RawTVNewAd] WHERE [PatternCODE] = @PatternCode))

				BEGIN

				UPDATE [RawTVNewAd] SET IngestionStatus = 1 WHERE [PatternCODE] = @PatternCode

				END

			END 

			END



			-- Insert AD records into TVPattern table



			IF(@CSCTrans = 1 AND  @ADTTrans = 1 AND @EPRCTrans = 1 OR @MMPRCTrans = 1)

			BEGIN

						

			IF(EXISTS(SELECT * FROM [RawTVNewAd] WHERE [PatternCODE] = @PatternCode))

			BEGIN

			--Fetching sourcefilename and priority from RawTVNewAds

			SELECT @SourceFileName = InputFileName FROM [RawTVNewAd] WHERE [PatternCODE] = @PatternCode

			SELECT @Priority = [Priority] FROM [RawTVNewAd] WHERE [PatternCODE] = @PatternCode



			

			--Check is Ethnic PR code processed

			IF(@FakeEthnicPRCode IS NOT NULL OR  @FakeEthnicPRCode != '')

			BEGIN

				SET @FinalPRCode = @FakeEthnicPRCode

			END



			IF(@FakeEthnicPatternCode IS NOT NULL OR  @FakeEthnicPatternCode != '')

			BEGIN

				SET @FinalPRCode = @FakeEthnicPatternCode

			END

						

			--Check is MM PR code processed

			IF(@FakeMMPatternCode IS NOT NULL OR  @FakeMMPatternCode != '')

			BEGIN

				SET @FinalPRCode = @FakeMMPatternCode

			END

			

			--Insert valid records into TVPatterns

			IF(NOT EXISTS(SELECT * FROM [TVPattern] WHERE [TVPatternCODE] = @FinalPRCode) AND @FinalPRCode != '')

			BEGIN
			print('INSERT INTO TVPatterns')
			--INSERT INTO TVPatterns

			--(

			--PK_PRCode,

			--OriginalPRCode,

			--SrcFileName,

			--[Priority],

			--WorkType,

			--CreateDTM,

			--CreatedBy

			--)

			--VALUES

			--(

			--@FinalPRCode,

			--@PatternCode,

			--@SourceFileName,

			--@Priority,

			--1,

			--GETDATE(),

			--1

			--)

			END

			---- Insert Occurrence records into OccurrencedetailsTV table	

			IF(@FinalPRCode != '')

			BEGIN
			PRINT('INSERT INTO OccrncDetailsTV')
			--INSERT INTO OccrncDetailsTV

			--(

			--FK_TVRecordingScheduleId,

			--FK_PRCode,

			--AirDate,

			--AirTime,

			--AdLength,

			--CaptureStationCode,

			--InputFileName,

			--CaptureTime,

			--CreateDTM,

			--CaptureDate

			--)

			--VALUES

			--(

			--@TVRecordingScheduleId,

			--@FinalPRCode,

			--@RawOccrncAirDate,

			--(SELECT CaptureTime FROM #TempRawOccrncTVPlaylist WHERE RowId = @RowCountTempRawOccrncTVPlaylist),

			--(SELECT [Length] FROM #TempRawOccrncTVPlaylist WHERE RowId = @RowCountTempRawOccrncTVPlaylist),

			--(SELECT CaptureStationCode FROM #TempRawOccrncTVPlaylist WHERE RowId = @RowCountTempRawOccrncTVPlaylist),

			--(SELECT InputFileName FROM #TempRawOccrncTVPlaylist WHERE RowId = @RowCountTempRawOccrncTVPlaylist),

			--(SELECT CaptureTime FROM #TempRawOccrncTVPlaylist WHERE RowId = @RowCountTempRawOccrncTVPlaylist),

			--GETDATE(),

			--(SELECT AirDateTime FROM #TempRawOccrncTVPlaylist WHERE RowId = @RowCountTempRawOccrncTVPlaylist)

			--)

			SET @InsertCountOccrncDetailsTV = @InsertCountOccrncDetailsTV + 1
			select(@InsertCountOccrncDetailsTV)
			END

			-- Insert records to PatternMasterStagingTV from TVPatterns table			

			END		

			END	

			PRINT('@RowCount:'+convert(varchar(10),@RowCountTempRawOccrncTVPlaylist))
			--SELECT @RowCount = @RowCount + 1
			SELECT @RowCountTempRawOccrncTVPlaylist = @RowCountTempRawOccrncTVPlaylist + 1

			END
			--Asit
			SELECT @InsertCountOccrncDetailsTV AS InsertCountOccrncDetailsTV

			IF(@InsertCountOccrncDetailsTV > 0)
			BEGIN
			INSERT INTO TVIngestionLog
				(
				SrcFileName,
				[OccurrencesCountInFile],
				[OccurrencesInserted],
				[LogEntryDT]
				)
				VALUES
				(
				@InputFileName,
				@TotalRowsTempTable,
				@InsertCountOccrncDetailsTV,
				GETDATE()
				)

				--UPDATE TVIngestionLog
				--SET	
				--OccrncsInserted = @InsertCountOccrncDetailsTV,
				--LogEntryDTM = GETDATE()
				--WHERE SrcFileName = @InputFileName
			END
			--SELECT @RowCountTempRawOccrncTVPlaylist = @RowCountTempRawOccrncTVPlaylist + 1
		END

		
		


		INSERT INTO @TVPatterns

		(

		PK_PRCode,

		OriginalPRCode

		)

		SELECT 

		[TVPatternCODE],

		OriginalPRCode

		FROM [TVPattern]



		--SELECT * FROM @TVPatterns



		DECLARE @TotalTVPatternRows INT,

				@PatternRows INT



		SELECT @TotalTVPatternRows =0,

			   @PatternRows = 1



		SELECT @TotalTVPatternRows = COUNT(*) FROM @TVPatterns



		WHILE @TotalTVPatternRows > 0

		BEGIN

			SET @TotalTVPatternRows = @TotalTVPatternRows - 1

				SELECT @FK_PRCode = [PK_PRCode] FROM @TVPatterns WHERE RowId = @PatternRows

				SELECT @PatternMasterId = [PatternID] FROM [OccurrenceDetailTV] WHERE [PRCODE] = @FK_PRCode

				SELECT @AdId = [AdID] FROM [OccurrenceDetailTV] WHERE [PRCODE] = @FK_PRCode



				IF(@PatternMasterId IS NULL AND @AdId IS NULL)

				BEGIN

				IF(@Priority < 5)

				BEGIN
				PRINT('INSERT INTO PatternMasterStgTV')
				--INSERT INTO PatternMasterStgTV

				--(

				--FK_CreativeSignature

				--)

				--VALUES

				--(

				--@FK_PRCode

				--)

				END

				END

			SET @PatternRows = @PatternRows + 1

		END	

		delete from @TVPatterns

		--select * from PatternMasterStgTV

	  COMMIT TRANSACTION 

	  END try 

      BEGIN catch 

          DECLARE @Error   INT, 

                  @Message VARCHAR(4000), 

                  @LineNo  INT 



          SELECT @Error = Error_number(), 

                 @Message = Error_message(), 

                 @LineNo = Error_line() 



          RAISERROR ('sp_TVIngestionForAdAndOccrncData: %d: %s',16,1,@Error,@Message,@LineNo); 

		  ROLLBACK TRANSACTION 

      END catch; 

  END;