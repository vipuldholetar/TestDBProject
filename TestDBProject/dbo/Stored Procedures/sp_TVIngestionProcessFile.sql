CREATE PROCEDURE [dbo].[sp_TVIngestionProcessFile]
	@pFileToProcess varchar(100)
AS
BEGIN
	SET NOCOUNT ON;

	-- BEGIN TRY 

		  -- exec [dbo].[sp_ProcessExecutionStep] 'TVIngestionProcess', 'Start Process File'
          -- Memory variables
			declare @totalRowCount int
			declare @currentRowId int

			declare @originalPattern varchar(20)
			declare @captureStation varchar(10)
			declare @airDTM datetime
			declare @captureTime time(7)
			declare @adLength int
			declare @creationDate datetime
			declare @mtStationId int
			declare @recordingScheduleId int
			declare @translatedAirDate datetime
			declare @ethnicPRCode varchar(20)
			declare @InsertCountOccrncDetailsTV int
			declare @ReExportCheckCaptureStation varchar(10)
			declare @ReExportCheckMinAirDateTime datetime
			declare @ReExportCheckMaxAirDateTime datetime
			declare @ReExportCheckCaptureTime time(7)
			declare @ReExportCheckMinTranslatedAirDateTime datetime
			declare @ReExportCheckMaxTranslatedAirDateTime datetime
			declare @SoftDeleteCount int
			declare @startPlayListHour int
			declare @endPlayListHour int
			declare @playListCaptureCode varchar(2)
			declare @playListDate varchar(8)
			declare @playListOP varchar(5)
			declare @FileSkippedFor0024 int = 0
			declare @step varchar(100)

  
			-- temp table to hold data for a given filename to process
			DECLARE @playlistData TABLE
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
				[IngestionStatus] [varchar](200),
				[Station] [varchar](4)
			);

			declare @reexportData TABLE
			(
				[RowId] [INT] IDENTITY(1,1) NOT NULL,
				[StationID] int not null,
				[CaptureStationCode] [varchar](200),
				[MinAirDateTime] [datetime],
				[MaxAirDateTime] [datetime],
				[CaptureTime] [time](7)
			);

			--get information for re-export logic
			-- exec [dbo].[sp_ProcessExecutionStep] 'TVIngestionProcess', 'Start Reexport Test and Process'
			select @startPlayListHour = SUBSTRING(@pFileToProcess,14,2), @endPlayListHour = SUBSTRING(@pFileToProcess,17,2)
			, @playListCaptureCode = substring(@pFileToProcess,4,2), @playListDate = substring(@pFileToProcess,7,6)
			, @playListOP = substring(@pFileToProcess,20,charindex('_',@pFileToProcess,20)-20)

			if @startPlayListHour + 1 = @endPlayListHour --and exists (select 1 from OccurrenceDetailTV with (nolock) where InputFileName like 'PL_'+ @playListCaptureCode + '_' + @playListDate + '_00-24_' + @playListOP + '%')
			begin
			   -- 24 hour file previously ingested
			   -- get min/max airdate from PlayList
			   select @ReExportCheckCaptureStation = CaptureStationCode, @ReExportCheckCaptureTime = min(CaptureTime), @ReExportCheckMinAirDateTime = min(AirDateTime), @ReExportCheckMaxAirDateTime = max(AirDateTime)
			   from RawTVPlaylist 
			   where InputFileName = @pFileToProcess and IngestionStatus = 0
			   group by CaptureStationCode

			   EXEC [dbo].[sp_TVIngestionCapturecodeTranslation] 
							@ReExportCheckCaptureStation,
							@ReExportCheckMinAirDateTime,
							@ReExportCheckCaptureTime,
							@MTStationId = @mtStationId OUTPUT,
							@RecordingScheduleId = @recordingScheduleId OUTPUT

						-- Get translated start air date/time
				EXEC [dbo].[sp_TVIngestionAirTimeTranslation]
					@MTStationId,
					@ReExportCheckMinAirDateTime,
					@TranslatedAirDate = @ReExportCheckMinTranslatedAirDateTime OUTPUT

						-- Get translated end air date/time
				EXEC [dbo].[sp_TVIngestionAirTimeTranslation]
					@MTStationId,
					@ReExportCheckMaxAirDateTime,
					@TranslatedAirDate = @ReExportCheckMaxTranslatedAirDateTime OUTPUT


			   if exists(select top 1 * from OccurrenceDetailTV with (nolock) where InputFileName like 'PL_'+ @playListCaptureCode + '_' + @playListDate + '_00-24_' + @playListOP + '%' and AirDT between @ReExportCheckMinTranslatedAirDateTime and @ReExportCheckMaxTranslatedAirDateTime ) 
			   begin
			      -- we found ingested records from 24 hour file, so skip hourly playlist file
				  update RawTVPlayList
				  set IngestionStatus = 2, IngestionDT = getdate()
				  where InputFileName = @pFileToProcess 

				  select @FileSkippedFor0024 = 1

				  return
				end
			end

			begin
				-- Select distinct filenames from RawTVPlaylist for which Ingestion Status is not 1
				insert into @playlistData 
				select * from RawTVPlaylist where InputFileName = @pFileToProcess and IngestionStatus = 0 order by RawTVPlaylistID

				-- Begin MI-1158:  delete any existing occurrences between min/max air date/time for current play list file.  Code assumes play list only ever contains one station
				insert into @reexportData
				select stationID, captureStationCode, min(AirDateTime), max(AirDateTime), min(CaptureTime)
				from (
				select (select 
								[TVStationID]
							from 
								TVRecordingSchedule s
							where
								s.CaptureStationCode = r.CaptureStationCODE and
								r.AirDateTime between [EffectiveStartDT] and isnull([EffectiveEndDT],getdate()) and
								r.CaptureTime BETWEEN cast([StartDT] as time) AND cast([EndDT] as time) and
								charindex(case datepart(WeekDay,r.AirDateTime) when 1 then 'U' when 2 then 'M' when 3 then 'T' when 4 then 'W' when 5 then 'H' when 6 then 'F' when 7 then 'S' end, WeekDays) > 0
				) stationID, r.captureStationCode, r.AirDateTime, r.CaptureTime
				from @playlistData r
				) q
				group by stationID, CaptureStationCode
				
				select @totalRowCount = count(*) from @reexportData
				select @currentRowId = 1
				select @SoftDeleteCount = 0
				WHILE @currentRowId <= @totalRowCount
				BEGIN
				  BEGIN TRANSACTION
						select @ReExportCheckCaptureStation = CaptureStationCode, @ReExportCheckMinAirDateTime = MinAirDateTime, @ReExportCheckMaxAirDateTime = MaxAirDateTime, @ReExportCheckCaptureTime = CaptureTime
						from @reexportData
						where [RowId]=@currentRowId

						EXEC [dbo].[sp_TVIngestionCapturecodeTranslation] 
							@ReExportCheckCaptureStation,
							@ReExportCheckMinAirDateTime,
							@ReExportCheckCaptureTime,
							@MTStationId = @mtStationId OUTPUT,
							@RecordingScheduleId = @recordingScheduleId OUTPUT

						-- Get translated start air date/time
						EXEC [dbo].[sp_TVIngestionAirTimeTranslation]
							@MTStationId,
							@ReExportCheckMinAirDateTime,
							@TranslatedAirDate = @ReExportCheckMinTranslatedAirDateTime OUTPUT

						-- Get translated end air date/time
						EXEC [dbo].[sp_TVIngestionAirTimeTranslation]
							@MTStationId,
							@ReExportCheckMaxAirDateTime,
							@TranslatedAirDate = @ReExportCheckMaxTranslatedAirDateTime OUTPUT

						-- get soft delete count
						select @SoftDeleteCount = count(*) + @SoftDeleteCount
						from [OccurrenceDetailTV]
						where [StationID] = @mtStationID
						and [AirDT] between @ReExportCheckMinTranslatedAirDateTime and @ReExportCheckMaxTranslatedAirDateTime

						-- soft delete previously imported occurrences
						update [OccurrenceDetailTV]
						set [Deleted] = 1
						where [StationID] = @mtStationID
						and [AirDT] between @ReExportCheckMinTranslatedAirDateTime and @ReExportCheckMaxTranslatedAirDateTime
						and [Deleted] is null

					-- move to next row
					select @currentRowId = @currentRowId+1
					COMMIT TRANSACTION
				END
				-- exec [dbo].[sp_ProcessExecutionStep] 'TVIngestionProcess', 'Finish Reexport Test and Process'
				-- End MI-1158
			

				select @totalRowCount = count(*) from @playlistData
				select @step = 'Start Ingestion:  ' + @pFileToProcess
				exec [dbo].[sp_ProcessExecutionStep] 'TVIngestionProcess', @step, @totalRowCount

				select @currentRowId = 1
				SET @InsertCountOccrncDetailsTV = 0
				-- exec [dbo].[sp_ProcessExecutionStep] 'TVIngestionProcess', 'Start Loop'
				WHILE @currentRowId <= @totalRowCount
				BEGIN
				  BEGIN TRANSACTION
					select 
						@originalPattern=[PatternCode], 
						@captureStation=[CaptureStationCode],
						@airDTM=[AirDateTime],
						@captureTime=[CaptureTime],
						@adLength=[Length],
						@creationDate=[CreateDTM]
					from @playlistData where [RowId]=@currentRowId

					-- Capture Code Translation

					EXEC [dbo].[sp_TVIngestionCapturecodeTranslation] 
					@captureStation,
					@airDTM,
					@CaptureTime,
					@MTStationId = @mtStationId OUTPUT,
					@RecordingScheduleId = @recordingScheduleId OUTPUT

					--print @currentRowId
					--print 'MT Station ID - ' + convert(varchar(10),@mtStationId)
					--print 'Recording Schedule ID - ' + convert(varchar(10),@recordingScheduleId)

					-- skip to next record if recordign schedule not found
					if (@mtStationId is null) 
					BEGIN
					
						-- Updating RawTVPlaylist with ingestionstatus = 1
						--UPDATE RawTVPlaylist SET IngestionStatus = 1 WHERE PatternCode = @originalPattern

						Insert INTO [dbo].[RawTVPlaylistError] 
						([PatternCODE], InputFileName, [CaptureStationCODE], AirDateTime, CaptureTime, Length, [CreatedDT], [IngestionDT], IngestionStatus, Station)
						Select  [PatternCode],[InputFileName],[CaptureStationCode],[AirDateTime],[CaptureTime],[Length],[CreateDTM],[IngestionDTM],[IngestionStatus], [Station] from @playlistData 
						where [RowId]=@currentRowId-- PatternCode = @originalPattern and AirDateTime = @airDTM and  InputFileName= @pFileToProcess

						-- Updating RawTVNewAds with ingestionstatus = 1
						IF(EXISTS(SELECT * FROM [RawTVNewAd] WHERE [PatternCODE] = @originalPattern))
						BEGIN
							UPDATE [RawTVNewAd] SET IngestionStatus = 1 WHERE [PatternCODE] = @originalPattern
							--INSERT INTO [dbo].[RawTVNewAdsError] (PK_Id, PatternCode, InputFileName, Length, Priority, CreateDTM, IngestionDTM, IngestionStatus)
							--Select [PK_Id], [PatternCode],[InputFileName],[Length],1,[CreateDTM],[IngestionDTM],[IngestionStatus] from @playlistData 
							--where PatternCode = @originalPattern and InputFileName= @pFileToProcess
						END

						select @currentRowId = @currentRowId+1
						continue
					END

					-- Air Time Translation

					EXEC [dbo].[sp_TVIngestionAirTimeTranslation]
					@mtStationId,
					@airDTM,
					@TranslatedAirDate = @translatedAirDate OUTPUT

					--print 'Original Airtime - ' + convert(varchar(25),@airDTM)
					--print 'Translated Airtime - ' + convert(varchar(25),@translatedAirDate)

					-- Ethnic Pattern Code Translation

					/*  MI-1186:  No longer translate Ethnic PR Codes 
					EXEC [dbo].[sp_TVIngestionEthnicPRCodeTranslation]
					@mtStationId,
					@originalPattern,
					@EthnicPRCode = @ethnicPRCode OUTPUT

					--print 'Original PRCode - ' + @originalPattern
					--print 'Ethnic PRCode - ' + @ethnicPRCode
					*/
					--MI-1186:  added line below so that @ethnicPRCode is set consistent with no translation
					select @ethnicPRCode = @originalPattern
					 
					-- MM Pattern Code Translation (PENDING) as per David, will be done as part of WS7.5

					-- Populate all staging tables  

					EXEC [dbo].[sp_TVIngestionPopulateStaging]
					@ethnicPRCode,
					@originalPattern,
					@pFileToProcess,
					@recordingScheduleId,
					@translatedAirDate,
					@adLength,
					@captureStation,
					@captureTime,
					@airDTM,
					@MTStationId

					SET @InsertCountOccrncDetailsTV = @InsertCountOccrncDetailsTV + 1

					-- move to next row
					select @currentRowId = @currentRowId+1
					COMMIT TRANSACTION
				END
				select @step = 'Finish Ingestion:  ' + @pFileToProcess
			    exec [dbo].[sp_ProcessExecutionStep] 'TVIngestionProcess', @step
            END;

			WITH q as (select top 1 * from TVIngestionLog with (nolock) where SrcFileName = @pFileToProcess order by TVIngestionLogID desc)
			UPDATE q
			SET	
			[OccurrencesInserted] = @InsertCountOccrncDetailsTV,
			[OccurrencesDeleted] = @SoftDeleteCount,
			[FileSkippedFor0024] = @FileSkippedFor0024,
			[LogEntryDT] = GETDATE();
	/*
		END TRY 

		BEGIN CATCH 
		    DECLARE @Error   INT, 
		            @Message VARCHAR(4000), 
		            @LineNo  INT 

		    SELECT @Error = Error_number(), 
		           @Message = Error_message(), 
		           @LineNo = Error_line() 

		    RAISERROR ('sp_TVIngestionProcessFile: %d: %s %d',16,1,@Error,@Message, @LineNo); 

		    ROLLBACK TRANSACTION 
		END CATCH; 
		*/
END