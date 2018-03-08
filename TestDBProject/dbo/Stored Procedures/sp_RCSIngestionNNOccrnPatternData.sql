-- =============================================          
-- Author:    Govardhan.R          
-- Create date: 04/07/2015          
-- Description:  Process RCS Ingestion Process          
-- Query : exec sp_RCSIngestionNNOccrnPatternData '2485','3/18/2015 12:59:46 AM','3/18/2015 1:00:00 AM','340868146','M2209601-20223710','2161525','308','15616141426','Goodwin College'         
-- =============================================          
CREATE PROCEDURE [dbo].[sp_RCSIngestionNNOccrnPatternData] (
	@StationId AS INT
	,@StartTime AS DATETIME
	,@EndTime AS DATETIME
	,@AcId AS BIGINT
	,@CreativeId AS VARCHAR(255)
	,@PaId AS INT
	,@ClassId AS INT
	,@SeqId AS BIGINT
	,@AcctName AS VARCHAR(255)
	,@AcIdCreativeIdUseCase AS CHAR(2)
	,@AdvertiserName as varchar(256)
	,@ClassName as varchar(256)
	)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		BEGIN TRANSACTION

		DECLARE @AccountID AS INT
			,@AdvMap AS BIT
			,@AccountMap AS BIT
			,@ClassMap AS BIT
			,@PatterMasterStagingID AS INT
			,@PatternId AS INT
			,@OccurrenceDetailID AS INT
			,@AutoIndexing AS BIT
			,@RadioLanguageID AS INT
			,@AdvMapAutoIndexFlag AS BIT
			,@AccountMapAutoIndexFlag AS BIT
			,@AutoIndexFlag AS BIT
			,@WWTRulePassed AS BIT
			,@MediaStream AS VARCHAR(50)

		SELECT @MediaStream = ConfigurationID
		FROM [Configuration]
		WHERE SYSTEMNAME = 'ALL'
			AND COMPONENTNAME = 'MEDIA STREAM'
			AND VALUETITLE = 'Radio'

		SELECT @RadioLanguageID = [LanguageID]
		FROM [RadioStation]
		WHERE [RadioStationID] = @StationId
		AND @StartTime between EffectiveDT and EndDT

		SELECT @AccountID = [RCSAcctID]
		FROM [RCSAcct]
		WHERE [Name] = @AcctName

		--Insert the data to RCSCreatives table.        
		INSERT INTO [RCSCreative] (
			[RCSCreativeID]
			, [RCSAcctID]
			,[RCSAdvID]
			,[RCSClassID]
			,[Deleted]
			,RCSSeqForCreation
			,[CreatedDT]
			,[CreatedByID]
			,[CreativeLength]
			)
		VALUES (
			@CreativeId
			,(select RCSAcctID from [RCSAcct] where Name = @AcctName)
			,(select RCSAdvId from [RCSAdv] where Name = @AdvertiserName)
			,(select RCSClassID from [RCSClass] where Name = @ClassName)
			,0
			,@SeqId
			,Getdate()
			,1
			, datediff(second,@StartTime,@EndTime)
			)

		--Insert the data to RCSACIDTORCSCREATIVEIDMAP table.        
		INSERT INTO [RCSAcIdToRCSCreativeIdMap] (
			[RCSAcIdToRCSCreativeIdMapID]
			,[RCSCreativeID]
			,[Deleted]
			,RCSInitialSeq
			,[CreatedDT]
			,[CreatedByID]
			)
		VALUES (
			@AcId
			,@CreativeId
			,0
			,@SeqId
			,Getdate()
			,1
			)

		--Insert the data to OCCURRENCEDETAILSRA table.    
		select @OccurrenceDetailID = OccurrenceDetailRAID 
		from OccurrenceDetailRA 
		where RCSSequenceID = @SeqId

		if (@OccurrenceDetailID is not null)
			begin    
				INSERT INTO [OccurrenceDetailRA] (
					[RCSAcIdID]
					,[PatternId]
					,[AirDT]
					,[RCSStationID]
					,LiveRead
					,[RCSSequenceID]
					,[AirStartDT]
					,[AirEndDT]
					,[Deleted]
					,[CreatedDT]
					,[CreatedByID]
					)
				VALUES (
					@AcId
					, (select PatternID from [Pattern] where MediaStream = @MediaStream and [CreativeSignature] = @CreativeId)
					,@StartTime
					,@StationId
					,0
					,@SeqId
					,@StartTime
					,@EndTime
					,0
					,Getdate()
					,1
					)

				SELECT @OccurrenceDetailID = @@IDENTITY
			end

		--Get Autoindex values from Map tables.        
		SELECT @AdvMap = case [Priority] when 1 then 1 else 0 end,  @AdvMapAutoIndexFlag = Isnull([AutoIndexing], 0)
		FROM [dbo].[AdvertiserMap] join RCSAdv on RCSAdvId = RCSAdvertiserID
		WHERE Name = @AdvertiserName
			AND [Deleted] = 0

		SELECT @AccountMap = case [Priority] when 1 then 1 when 5 then 1 else 0 end, @AccountMapAutoIndexFlag = Isnull([AutoIndexing], 0)
		FROM [dbo].[AcctMap] join RCSAcct on RCSAcct.RCSAcctID = [AcctMap].[RCSAcctID]
		WHERE Name = @AcctName
			AND [AcctMap].[Deleted] = 0


		SELECT @ClassMap = case [Priority] when 1 then 1 else 0 end
		FROM [dbo].[ClassMap] join RCSClass on RCSClass.RCSClassId = ClassMap.RCSClassID
		WHERE Name = @ClassName
			AND [IsDeleted] = 0

		SET @AutoIndexFlag = 0;
		SET @WWTRulePassed = 0;

		--Verify WWT Rules .        
		IF (
				((@ClassMap = 1)
				OR (@AdvMap = 1))
				OR (@AccountMap <> 5)
				)
		BEGIN
			SET @AutoIndexFlag = 0;
			SET @WWTRulePassed = 1;
		END
		ELSE IF (
				(@AdvMapAutoIndexFlag = 1)
				OR (@AccountMapAutoIndexFlag = 1)
				)
		BEGIN
			SET @AutoIndexFlag = 1;
			SET @WWTRulePassed = 1;
		END

		update [RCSCreative]
		set Priority = @WWTRulePassed
		where RCSCreativeID = @CreativeId

			if not exists(select 1 from Pattern where MediaStream = @MediaStream and CreativeSignature = @CreativeId)
			  begin
					-- insert to Pattern table
					INSERT INTO [Pattern] (
						[MediaStream]
						,[Priority]
						,[Status]
						,[CreativeSignature]
						,[AdvertiserNameSuggestion]
						)
					VALUES (
						@MediaStream
						,@WWTRulePassed
						,'Valid'
						,@CreativeId
						,@AdvertiserName
						)

					SELECT @PatternID = @@IDENTITY

					UPDATE [OccurrenceDetailRA]
					SET PatternId = @PatternID
					WHERE OccurrenceDetailRAID = @OccurrenceDetailID

			end

		IF (@WWTRulePassed = 1)
		BEGIN
		  if not exists (select 1 from PatternStaging where MediaStream = @MediaStream and CreativeSignature = @CreativeId) 
		  and exists (select 1 from Pattern where MediaStream = @MediaStream and CreativeSignature = @CreativeId and AdId is null)
		  begin

				--Insert data to Pattern Staging RA table.       
				INSERT INTO [PatternStaging] (
					[Priority]
					,[PatternId]
					,MediaStream
					,[Status]
					,AutoIndexing
					,CreativeIdAcIdUseCase
					,[CreatedDT]
					,[CreatedByID]
					,[LanguageID]
					,[CreativeSignature]
					,[AdvertiserNameSuggestion]
					)
				VALUES (
					@WWTRulePassed
					,@PatternId
					,@MediaStream
					,'Valid'
					,@AutoIndexFlag
					,@AcIdCreativeIdUseCase
					,Getdate()
					,1
					,isnull(@RadioLanguageID, 1)
					,@CreativeId
					,@AdvertiserName
					)

				SELECT @PatterMasterStagingID = @@IDENTITY

				--Insert data to PatternDetailRaStaging table.     
				INSERT INTO [PatternDetailRAStaging] (
					[PatternStgID]
					,[RCSCreativeID]
					,[CreatedDT]
					,[CreatedByID]
					)
				VALUES (
					@PatterMasterStagingID
					,@CreativeId
					,Getdate()
					,1
					)
			END
		END

		COMMIT TRANSACTION
	END TRY

	BEGIN CATCH
		DECLARE @Error INT
			,@Message VARCHAR(4000)
			,@LineNo INT

		SELECT @Error = Error_number()
			,@Message = Error_message()
			,@LineNo = Error_line()

		RAISERROR (
				'sp_RCSIngestionNNOccrnPatternData: %d: %s'
				,16
				,1
				,@Error
				,@Message
				,@LineNo
				);

		ROLLBACK TRANSACTION
	END CATCH;
END;