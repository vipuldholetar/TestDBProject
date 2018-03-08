-- ========================================================================
-- Author: 
-- Create date: 09/05/2015
-- Description:	This stored procedure Processes a single Playlist file
-- =========================================================================
CREATE PROCEDURE [dbo].[sp_TVIngestionProcessFile_Old]
	@pFileToProcess varchar(100)
AS
BEGIN
	SET NOCOUNT ON;

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
		[Station] [varchar] (4)
	);

	-- Select distinct filenames from RawTVPlaylist for which Ingestion Status is not 1
	insert into @playlistData 
	select * from RawTVPlaylist where InputFileName = @pFileToProcess

	select @totalRowCount = count(*) from @playlistData
	select @currentRowId = 1
	SET @InsertCountOccrncDetailsTV = 0
		
	WHILE @currentRowId <= @totalRowCount
	BEGIN
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

		print @currentRowId
		print 'MT Station ID - ' + convert(varchar(10),@mtStationId)
		print 'Recording Schedule ID - ' + convert(varchar(10),@recordingScheduleId)

		-- skip to next record if recordign schedule not found
		if (@mtStationId is null) 
		BEGIN
			
			-- Updating RawTVPlaylist with ingestionstatus = 1
			--UPDATE RawTVPlaylist SET IngestionStatus = 1 WHERE PatternCode = @originalPattern

			Insert INTO [dbo].[RawTVPlaylistError] 
			([PatternCODE], InputFileName, [CaptureStationCODE], AirDateTime, CaptureTime, Length, [CreatedDT], [IngestionDT], IngestionStatus)
			Select  [PatternCode],[InputFileName],[CaptureStationCode],[AirDateTime],[CaptureTime],[Length],[CreateDTM],[IngestionDTM],[IngestionStatus] from @playlistData 
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

		print 'Original Airtime - ' + convert(varchar(25),@airDTM)
		print 'Translated Airtime - ' + convert(varchar(25),@translatedAirDate)

		-- Ethnic Pattern Code Translation

		EXEC [dbo].[sp_TVIngestionEthnicPRCodeTranslation]
		@mtStationId,
		@originalPattern,
		@EthnicPRCode = @ethnicPRCode OUTPUT

		print 'Original PRCode - ' + @originalPattern
		print 'Ethnic PRCode - ' + @ethnicPRCode

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
		@airDTM

		SET @InsertCountOccrncDetailsTV = @InsertCountOccrncDetailsTV + 1

		-- move to next row
		select @currentRowId = @currentRowId+1
	END

	IF(@InsertCountOccrncDetailsTV > 0)
	BEGIN
		UPDATE TVIngestionLog
		SET	
		[OccurrencesInserted] = @InsertCountOccrncDetailsTV,
		[LogEntryDT] = GETDATE()
		WHERE SrcFileName = @pFileToProcess
	END
END