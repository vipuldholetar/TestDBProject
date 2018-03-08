-- ========================================================================
-- Author: Nagarjuna
-- Create date: 09/05/2015
-- Description:	This stored procedure populates all staging tables
-- =========================================================================
CREATE PROCEDURE [dbo].[sp_TVIngestionPopulateStaging_Old]
	@translatedPRCode varchar(20),
	@originalPRCode varchar(20),
	@sourceFileName varchar(100),
	@recordingScheduleId int,
	@airDT datetime,
	@adLength int,
	@captureStation varchar(10),
	@captureTime time(7),
	@actualAirDTM datetime
AS
BEGIN
	SET NOCOUNT ON;

	-- Memory variables
	declare @captureDate varchar(10)
	declare @priority int
	declare @firstAirDate datetime 
	declare @firstAirTime time(7)
	declare @adFileName varchar(100)
	declare @adId int
	declare @patternMasterId int
	
	-- Insert into TVPatterns 
	-- PK_PRCode,OriginalPRCode,SrcFileName,Priority,WorkType,CreateDTM,CreatedBy

	select @priority = [Priority], @adFileName = InputFileName from [RawTVNewAd] where [PatternCODE] = @originalPRCode
	if (@adFileName is not null)
	BEGIN
		select @captureDate = substring(@adFileName,4,6)
	END
	
	begin tran 
	if (not exists(select * from [TVPattern] where [TVPatternCODE] = @originalPRCode) and @adFileName is not null)
	BEGIN
		insert into [TVPattern]
			([TVPatternCODE],OriginalPRCode,SrcFileName,[Priority],WorkType,[CreatedDT],[CreatedByID])
		values 
			(@translatedPRCode,@originalPRCode,@adFileName,@priority,1,getdate(),1)

		--Delete raw ad record after successful ingestion
		delete from [RawTVNewAd] where [PatternCODE] = @originalPRCode and InputFileName= @adFileName
	END

	-- Insert into OccurrenceDetailsTV
	-- PK_Id,FK_PatternMasterId FK_AdID,FK_TVRecordingScheduleId FK_PRCode,AirDate,AirTime,AdLength,CaptureStationCode,InputFileName,CaptureTime,CreateDTM,CaptureDate,TVProgramID,TVEpisodeID
	select @adId = [AdID], @patternMasterId = [PatternID] from [OccurrenceDetailTV] 
	where [PRCODE] = @translatedPRCode and [PatternID] is not null
	
	insert into [OccurrenceDetailTV]	([PatternID], [AdID], [TVRecordingScheduleID], [PRCODE], [AirDT],
	 AirTime, AdLength, CaptureStationCode, InputFileName, [CaptureDT], [CreatedDT])
	values(@patternMasterId, @adId, @recordingScheduleId, @translatedPRCode, @airDT, @airDT, @adLength, 
		   @captureStation, @sourceFileName,getdate(),getdate())

	--Delete raw playlist record after successful ingestion
	--delete from RawTVPlaylist where PatternCode = @originalPRCode and AirDateTime = @actualAirDTM and  InputFileName= @sourceFileName

	-- Insert into PatternMasterStagingTV
	-- PK_Id,CreativeStagingID,FK_CreativeSignature,ScoreQ,IsQuery,IsException,LanguageId,MOTReasonCode,NoTakeReasonCode
	if (@adId is null)
	BEGIN

		if (not exists(select [CreativeSignature] from [PatternTVStg] where [CreativeSignature]=@translatedPRCode))
		BEGIN
		-- Find the PR code into TVPatterns table and if it is found then only insert into PatternMasterStgTv
		IF(EXISTS(SELECT [TVPatternCODE] FROM [TVPattern] WHERE OriginalPRCode = @originalPRCode))
			insert into [PatternTVStg]([CreativeSignature],[LanguageID])
			values(@translatedPRCode,1)
		END	    
		-- Ideally this language ID should come form TV Programs and assumed that it is updated by other 
		-- business process.
	END
	if (@@ERROR = 0)
		commit tran
	else
		rollback tran
		
END