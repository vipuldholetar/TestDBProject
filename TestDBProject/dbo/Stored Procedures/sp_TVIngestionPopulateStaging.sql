-- ========================================================================
-- Author: Nagarjuna
-- Create date: 09/05/2015
-- Description:	This stored procedure populates all staging tables
-- =========================================================================
CREATE PROCEDURE [dbo].[sp_TVIngestionPopulateStaging]
	@translatedPRCode varchar(20),
	@originalPRCode varchar(20),
	@sourceFileName varchar(100),
	@recordingScheduleId int,
	@airDT datetime,
	@adLength int,
	@captureStation varchar(10),
	@captureTime time(7),
	@actualAirDTM datetime,
	@stationID int
AS
BEGIN
	SET NOCOUNT ON;
	    BEGIN TRY 
		  -- exec [dbo].[sp_ProcessExecutionStep] 'TVIngestionProcess', 'Start Populate Staging'
          --BEGIN TRANSACTION 

			-- Memory variables
			declare @captureDate varchar(10)
			declare @priority int
			declare @firstAirDate datetime 
			declare @firstAirTime time(7)
			declare @adFileName varchar(100)
			declare @adId int
			declare @patternMasterId int
			declare @mediaStreamID int

			select @mediaStreamId = ConfigurationID
			from Configuration
			where ComponentName = 'Media Stream'
			and Value = 'TV'
			
			-- Insert into TVPatterns 
			-- PK_PRCode,OriginalPRCode,SrcFileName,Priority,WorkType,CreateDTM,CreatedBy

			select @priority = [Priority], @adFileName = InputFileName from [RawTVNewAd] where [PatternCODE] = @originalPRCode
			
			select @captureDate = cast(substring(@sourceFilename,7,2) + '-' +  substring(@sourceFilename,9,2) + '-' + substring(@sourceFilename,11,2) as date)
			
			if (not exists(select * from [TVPattern] where [TVPatternCODE] = @translatedPRCode))
			BEGIN
				insert into [TVPattern]
					([TVPatternCODE],OriginalPRCode,SrcFileName,[Priority],WorkType,[CreatedDT],[CreatedByID])
				values 
					(@translatedPRCode,@originalPRCode,isnull(@adFileName, @sourceFileName) ,@priority,1,getdate(),1)
			END

			if (not exists(select * from [Pattern] WITH(NOLOCK) where CreativeSignature = @translatedPRCode))
			BEGIN
				insert into Pattern
				(MediaStream, CreativeSignature, Priority, Status)
				values
				(@mediaStreamId, @translatedPRCode, isnull(@priority,1), 'Valid')

				--Delete raw ad record after successful ingestion
				--delete from [RawTVNewAd] where [PatternCODE] = @originalPRCode and InputFileName= @adFileName
				update [RawTVNewAd] 
				set IngestionDT = getdate(), IngestionStatus = 1
				where [PatternCODE] = @originalPRCode and InputFileName= @adFileName
			END

			-- Insert into OccurrenceDetailsTV
			-- PK_Id,FK_PatternMasterId FK_AdID,FK_TVRecordingScheduleId FK_PRCode,AirDate,AirTime,AdLength,CaptureStationCode,InputFileName,CaptureTime,CreateDTM,CaptureDate,TVProgramID,TVEpisodeID
			select @adId = [AdID], @patternMasterId = [PatternID] 
			from [Pattern] WITH(NOLOCK)
			where [CreativeSignature] = @translatedPRCode
			
			insert into [OccurrenceDetailTV]	([PatternID], [AdID], [TVRecordingScheduleID], [PRCODE], [AirDT],
			 AirTime, AdLength, CaptureStationCode, InputFileName, [CaptureDT], [CreatedDT], [StationID])
			values(@patternMasterId, @adId, @recordingScheduleId, @translatedPRCode, @airDT, @airDT, @adLength, 
				   @captureStation, @sourceFileName,cast(cast(@captureDate + ' ' + cast(@captureTime as varchar) as datetime2(7)) as datetime),getdate(), @stationID)

			--Delete raw playlist record after successful ingestion
			--delete from RawTVPlaylist where PatternCode = @originalPRCode and AirDateTime = @actualAirDTM and  InputFileName= @sourceFileName

			-- Insert into PatternMasterStagingTV
			-- PK_Id,CreativeStagingID,FK_CreativeSignature,ScoreQ,IsQuery,IsException,LanguageId,MOTReasonCode,NoTakeReasonCode
			if (@adId is null)
			BEGIN

				if (not exists(select [CreativeSignature] from [PatternStaging] WITH(NOLOCK) where [CreativeSignature]=@translatedPRCode and MediaStream = @mediaStreamId))
				BEGIN
				/*
				-- Find the PR code into TVPatterns table and if it is found then only insert into PatternMasterStgTv
				IF(EXISTS(SELECT [TVPatternCODE] FROM [TVPattern] WHERE OriginalPRCode = @originalPRCode))
					insert into [PatternTVStg]([CreativeSignature],[LanguageID])
					values(@translatedPRCode,1)
				*/
					insert into [PatternStaging]
					(MediaStream, PatternID, CreativeSignature, Priority, Status, WorkType, LanguageID)
					values
					(@mediaStreamId, @patternMasterId, @translatedPRCode, isnull(@priority,1), 'Valid', 1,
					(select EthnicGroupId from TVStation with (nolock) where TVStationID = (select top 1 StationID from OccurrenceDetailTV with (nolock) where PRCODE = @translatedPRCode order by AirDT))
					)
				END
				
					    
				-- Ideally this language ID should come form TV Programs and assumed that it is updated by other 
				-- business process.
			END

          --COMMIT TRANSACTION 
		  -- exec [dbo].[sp_ProcessExecutionStep] 'TVIngestionProcess', 'Finish Populate Staging'
      END TRY 

      BEGIN CATCH 
          DECLARE @Error   INT, 
                  @Message VARCHAR(4000), 
                  @LineNo  INT 

          SELECT @Error = Error_number(), 
                 @Message = Error_message(), 
                 @LineNo = Error_line() 

          RAISERROR ('sp_TVIngestionPopulateStaging: Line#: %d; %d: %s',16,1,@LineNo,@Error,@Message); 

          ROLLBACK TRANSACTION 
      END CATCH; 		
END