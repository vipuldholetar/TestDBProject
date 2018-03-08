-- =============================================     
-- Author:    Nagarjuna     
-- Create date: 07/17/2015     
-- Description:  This procedure is used to ingests the TV Ingestion raw pattern and occurrence data
-- Query : exec sp_TVIngestionForAdAndOccrncData

-- =============================================    
CREATE PROCEDURE [dbo].[sp_TVIngestionForAdAndOccrncData](@TVBatchData [dbo].[TVBatchData] readonly)
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

		DECLARE @RawTVPlaylist TABLE
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

		DECLARE @RawDistinctTVPlaylist TABLE
		(
		  [RowId] [INT] IDENTITY(1,1) NOT NULL,		  
		  [InputFileName] [varchar](200)		 
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
		  [OriginalPRCode] [varchar](200),
		  [Priority] INT		 
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
				@OccrncDistinctRowCount INT,
				@OccuncDistnictTotalRows INT,
				@InputFileName VARCHAR(200),
				@InsertCountOccrncDetailsTV INT,
				@MediaStream INT						

		SELECT @RowCount = 1, 
               @TotalRows = 0,
			   @CSCTrans = 0,
			   @ADTTrans = 0,
			   @EPRCTrans = 0,
			   @MMPRCTrans = 0,
			   @PatternRowCount = 1,
			   @TotalPatternRows = 0,
			   @OccrncDistinctRowCount = 1,
			   @OccuncDistnictTotalRows = 0,
			   @JPEGPath = '',
			   @MediaFilePath = '',
			   @FinalPRCode = '',
			   @InsertCountOccrncDetailsTV = 0,
			   @MediaStream = 144

		--Insert TV Occurrence data to @RawOccrncTVPlaylist
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
		--ORDER BY CreateDTM DESC
		--INNER JOIN TVMMPRCodes MM ON MM.OriginalPatternCode = TV.PatternCode

		--Insert RawOccurrencedistinctTVPlaylist table

		INSERT INTO @RawDistinctTVPlaylist
		(
		InputFileName
		)
		SELECT DISTINCT InputFileName FROM @TVBatchData

		--SELECT * FROM @RawDistinctTVPlaylist
		SELECT @OccuncDistnictTotalRows = COUNT(*) FROM @RawDistinctTVPlaylist

		WHILE @OccuncDistnictTotalRows > 0
		BEGIN
			SELECT @OccuncDistnictTotalRows = @OccuncDistnictTotalRows - 1
			SELECT @InputFileName = InputFileName FROM @RawDistinctTVPlaylist WHERE RowId = @OccrncDistinctRowCount
			delete from @RawTVPlaylist
			INSERT INTO @RawTVPlaylist
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
			[RawTVPlaylistID],
			[InputFileName],
			[CaptureStationCODE],
			[AirDateTime],
			[CaptureTime],
			[Length],
			[PatternCODE],
			[CreatedDT],
			[IngestionDT] 
			FROM RawTVPlaylist WHERE InputFileName = @InputFileName

			--select * from @RawTVPlaylist

			SELECT @TotalRows = COUNT(*) FROM @RawTVPlaylist	

				-- Looping trhough @RawTVPlaylist total count
				SET @InsertCountOccrncDetailsTV = 0
				
				WHILE @TotalRows > 0
				BEGIN
					SELECT @TotalRows = @TotalRows - 1
					

					SELECT @FakeEthnicPRCode = ''
					SELECT @FakeEthnicPatternCode = ''
					--select @ExistingEthnicPRCode = 'False'
					--select @ExistingMMPRCode = 'False'

					--Fetch AirDateTime from playlist file
					SELECT @RawOccrncAirDate = [AirDateTime] FROM @RawTVPlaylist WHERE RowId = @RowCount
					--Fetch PatternCode from playlist file
					SELECT @PatternCode = PatternCode FROM @RawTVPlaylist WHERE RowId = @RowCount
					--Fetch capturestationcode from playlist file
					SELECT @RawOccrncCaptureStationCode = [CaptureStationCode] FROM @RawTVPlaylist WHERE RowId = @RowCount
					--Fetch capture time from playlist file
					SELECT @CaptureTime = CaptureTime FROM @RawTVPlaylist WHERE RowId = @RowCount
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
						    IF (EXISTS(SELECT * FROM TVRecordingSchedule WHERE CaptureStationCode = @RawOccrncCaptureStationCode and @RawOccrncAirDate BETWEEN [EffectiveStartDT] AND isnull([EffectiveEndDT],getdate()) and @CaptureTime BETWEEN cast([StartDT] as time) AND cast([EndDT] as time)) )
							BEGIN 
								SET @CSCTrans = 1;
							    SELECT @TVRecordingScheduleId = [TVRecordingScheduleID] FROM TVRecordingSchedule WHERE CaptureStationCode = @RawOccrncCaptureStationCode and @RawOccrncAirDate BETWEEN [EffectiveStartDT] AND isnull([EffectiveEndDT],getdate()) and @CaptureTime BETWEEN cast([StartDT] as time) AND cast([EndDT] as time)
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
							
						IF(@EthnicGroupId != 2)
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

							--Creating new record into TVEthnicPRCodes
							INSERT INTO [TVEthnicPRCode]
							(
								[TVEthnicPRCodeID],
								[EthnicGroupID],
								OriginalPRCode,
								[CreatedDT]
							)
							VALUES
							(
							 @FakeEthnicPRCode,
								@EthnicGroupId,
								@PatternCode,
								GETDATE()
							)
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

										   --Creating new record into TVMMPRCodes
										   INSERT INTO [TVMMPRCode]
										   (
										    [TVMMPRCodeCODE],
											[ApprovedMarketID],
											OriginalPatternCode,
											ApprovedForAllMarkets,
											[EffectiveStartDT],									
											[CreatedDT],
											[CreatedByID],
											[ModifiedDT]
										   )
										   VALUES
										   (
										   @NewFakePatternCode,
										   @MarketId,
										   @PatternCode,
										   0,
										   GETDATE(),
										   GETDATE(),
										   1,
										   GETDATE()
										   )								   
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
					INSERT INTO [TVPattern]
					(
					[TVPatternCODE],
					OriginalPRCode,
					SrcFileName,
					[Priority],
					WorkType,
					[CreatedDT],
					[CreatedByID]
					)
					VALUES
					(
					@FinalPRCode,
					@PatternCode,
					@SourceFileName,
					@Priority,
					1,
					GETDATE(),
					1
					)

					--DELETE FROM RawTVNewAds WHERE PatternCode = @PatternCode

					END
					---- Insert Occurrence records into OccurrencedetailsTV table	
					IF(@FinalPRCode != '')
					BEGIN
					INSERT INTO [OccurrenceDetailTV]
					(
					[TVRecordingScheduleID],
					[PRCODE],
					[AirDT],
					AirTime,
					AdLength,
					CaptureStationCode,
					InputFileName,
					[CaptureDT],
					[CreatedDT]
					)
					VALUES
					(
					@TVRecordingScheduleId,
					@FinalPRCode,
					@RawOccrncAirDate,
					(SELECT CaptureTime FROM @RawTVPlaylist WHERE RowId = @RowCount),
					(SELECT [Length] FROM @RawTVPlaylist WHERE RowId = @RowCount),
					(SELECT CaptureStationCode FROM @RawTVPlaylist WHERE RowId = @RowCount),
					(SELECT InputFileName FROM @RawTVPlaylist WHERE RowId = @RowCount),
					(SELECT AirDateTime FROM @RawTVPlaylist WHERE RowId = @RowCount),
					GETDATE()
					)

					--DELETE FROM RawTVPlaylist WHERE PatternCode = @PatternCode
					SET @InsertCountOccrncDetailsTV = @InsertCountOccrncDetailsTV + 1

					END					
					END		
					END	
					SELECT @RowCount = @RowCount + 1
					
				END

				IF(@InsertCountOccrncDetailsTV > 0)
				BEGIN
				
				--SELECT @InsertCountOccrncDetailsTV AS InsertCountOccrncDetailsTV

					UPDATE TVIngestionLog
					SET	
					[OccurrencesInserted] = @InsertCountOccrncDetailsTV,
					[LogEntryDT] = GETDATE()
					WHERE SrcFileName = @InputFileName
				END

			SET @OccrncDistinctRowCount = @OccrncDistinctRowCount + 1
		END				
		
		--Insert records to PatternMasterStgTv Table
		INSERT INTO @TVPatterns
		(
		PK_PRCode,
		OriginalPRCode,
		[Priority]
		)
		SELECT 
		[TVPatternCODE],
		OriginalPRCode,
		[Priority]
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
				SELECT @Priority = [Priority] FROM @TVPatterns WHERE RowId = @PatternRows

				IF(@PatternMasterId IS NULL AND @AdId IS NULL)
				BEGIN
				IF(@Priority < 5)
				BEGIN

				IF (NOT EXISTS(SELECT * FROM [Pattern] WHERE MediaStream = @MediaStream and [CreativeSignature] = @FK_PRCode) )
				BEGIN
				INSERT INTO [PatternStaging]
				(
				[MediaStream],
				[CreativeSignature],
				[LanguageID],
				[Status]
				)
				VALUES
				(
				@MediaStream,
				@FK_PRCode,
				@EthnicGroupId,
				'Valid'
				)
				END				
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