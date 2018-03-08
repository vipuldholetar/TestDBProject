
-- ===========================================================================================================
-- Author		:	Karunakar
-- Create date	:	2nd September 2015
-- Description	:	This Procedure is Used to Perform QC Map Index 
--					1.Moving Data from Child tables to staging tables 
-- Execution	:	sp_ReviewQueueUpdatePatterQCMapMoveData 2218,145,29711029
-- Updated By	:	Ramesh Bangi for Online Display on 09/25/2015
--				:	Karunakar on 13th October 2015,Adding Mobile and Online Video Media Streams.
--					Arun Nair on 11/24/2015 - Added Auditby/On on Staging Tables for all MediaStream
--				:L.E. on 1/31/2017 - No longer delete from Pattern but update AdID to Null, add FK to PatternStaging MI-953
-- =========================================================================================================
CREATE PROCEDURE [dbo].[sp_ReviewQueueUpdatePatterQCMapMoveData] @Patternmasterid AS INT
	,@MediaStreamId AS INT
	,@UserId AS INT
	,@Language AS INT
	,@Adid AS INT
	,@DeleteOrphanAd AS INT = 0
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @CreativeSignature AS NVARCHAR(max) = ''
		DECLARE @CreativeMasterId AS INT
		DECLARE @OccurrenceId AS BIGINT
		DECLARE @CreativeStgId AS INT
		DECLARE @PatternStgId AS INT
		DECLARE @MediaStreamValue AS NVARCHAR(max) = ''
		DECLARE @MediaStream AS NVARCHAR(max) = ''
		DECLARE @PatternCount AS INT = 0

		SELECT @PatternCount = count(*)
		FROM [Pattern]
		WHERE [AdID] = @Adid

		IF @PatternCount = 1 AND @DeleteOrphanAd = 0
		BEGIN
			SELECT 0 AS result
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION

			SELECT @MediaStreamValue = Value
				,@MediaStream = ValueTitle
			FROM [dbo].[Configuration]
			WHERE ConfigurationID = @MediaStreamId

			-- Radio
			IF (@MediaStreamValue = 'RAD')
			BEGIN
				--Getting OccurrenceId
				SET @OccurrenceId = (
						SELECT [Creative].[SourceOccurrenceId]
						FROM [dbo].[Creative]
						INNER JOIN [Pattern] ON [Creative].pk_id = [Pattern].[CreativeID]
							AND [Pattern].[PatternID] = @Patternmasterid
						)

				-- Geeting CreativeMasterId and CreativeSignature From Patternmaster
				SELECT @CreativeMasterId = [CreativeID]
					,@CreativeSignature = CreativeSignature
				FROM [Pattern]
				WHERE [Pattern].[PatternID] = @Patternmasterid

				INSERT INTO [CreativeStaging] (
					Deleted
					,[CreatedDT]
					,[OccurrenceID]
					)
				VALUES (
					0
					,getdate()
					,@OccurrenceId
					)

				SET @CreativeStgId = Scope_identity();

				-- Move Records in PatternMaster to PatternMasterStg
				INSERT INTO [PatternStaging] (
					PatternID
					,CreativeSignature
					,[CreativeStgID]
					,[Priority]
					,[MediaStream]
					,[Status]
					,[AutoIndexing]
					,[CreativeIdAcIdUseCase]
					,
					--PatternStag.LanguageID ,
					[CreatedDT]
					,[CreatedByID]
					,[AuditedByID]
					,[AuditedDT]
					)
				SELECT PatternId
					,@CreativeSignature
					,@CreativeStgId
					,[Priority]
					,@MediaStreamId
					,[Status]
					,0
					,--Hard Coded Value
					'NN'
					,--Hard Coded Value
					--@Language,
					getdate()
					,@UserId
					,@UserId
					,getdate()
				FROM [Pattern]
				WHERE [Pattern].[PatternID] = @Patternmasterid

				SET @PatternStgId = Scope_identity();

				--Inserting PatternDetailRAStg 
				--insert into PatternDetailRAStaging([PatternStgID],[RCSCreativeID],[CreatedDT],[CreatedByID])
				-- Values(@PatternStgId,@CreativeSignature,getdate(),@UserId)
				--Move Records in CreativeDetailsRA to CreativeDetailsRAStg
				INSERT INTO [CreativeDetailStagingRA] (
					[CreativeStgID]
					,[MediaFormat]
					,[MediaFilePath]
					,[MediaFileName]
					,[FileSize]
					)
				SELECT @CreativeStgId
					,[FileTYpe]
					,[Rep]
					,[AssetName]
					,0 ----Hard Coded Value
				FROM [CreativeDetailRA]
				WHERE [CreativeDetailRA].[CreativeID] = @CreativeMasterId

				--Print('--Inserted--')
				--Updating OccrncDetailsRA
				UPDATE [OccurrenceDetailRA]
				SET [AdID] = NULL
				WHERE [OccurrenceDetailRA].[PatternID] = @Patternmasterid

				-- Deleting PatternMaster and Creativemaster
				--Delete from [Pattern] where [Pattern].[PatternID]=@Patternmasterid
				UPDATE [Pattern]
				SET AdID = NULL
				WHERE [Pattern].[PatternID] = @Patternmasterid

				DELETE
				FROM [Creative]
				WHERE [Creative].PK_Id = @CreativeMasterId

				UPDATE [RCSCreative]
				SET [Deleted] = 0
				WHERE [RCSCreativeID] = @CreativeSignature
			END

			-- Outdoor
			IF (@MediaStreamValue = 'OD')
			BEGIN
				--Getting OccurrenceId
				SET @OccurrenceId = (
						SELECT [Creative].[SourceOccurrenceId]
						FROM [dbo].[Creative]
						INNER JOIN [Pattern] ON [Creative].pk_id = [Pattern].[CreativeID]
							AND [Pattern].[PatternID] = @Patternmasterid
						)

				-- Geeting CreativeMasterId and CreativeSignature From Patternmaster
				SELECT @CreativeMasterId = [CreativeID]
					,@CreativeSignature = CreativeSignature
				FROM [Pattern]
				WHERE [Pattern].[PatternID] = @Patternmasterid

				INSERT INTO [CreativeStaging] (
					Deleted
					,[CreatedDT]
					,[OccurrenceID]
					)
				VALUES (
					0
					,getdate()
					,@OccurrenceId
					)

				SET @CreativeStgId = Scope_identity();

				-- Move Records in [dbo].[PatternMaster] to PatternMasterStagingODR
				INSERT INTO [dbo].[PatternStaging] (
					[PatternID]
					,--L.E. on 1/31/2017						
					[CreativeStgID]
					,[CreativeSignature]
					,[MediaStream]
					,--L.E. on 1/31/2017
					[LanguageID]
					,[CreatedDT]
					,[status]
					,--L.E. on 1/31/2017
					[CreatedByID]
					,[AuditedByID]
					,[AuditedDT]
					)
				SELECT @Patternmasterid
					,@CreativeStgId
					,@CreativeSignature
					,[MediaStream]
					,@Language
					,getdate()
					,[status]
					,@UserId
					,@UserId
					,Getdate()
				FROM [Pattern]
				WHERE [Pattern].[PatternID] = @Patternmasterid

				SET @PatternStgId = Scope_identity();

				--Move Records in [CreativeDetailODR] to [CreativeDetailsODRStg]
				INSERT INTO [dbo].[CreativeDetailStagingODR] (
					CreativeStagingID
					,CreativeFileType
					,CreativeRepository
					,CreativeAssetName
					,CreativeFileSize
					,AdFormatID
					)
				SELECT @CreativeStgId
					,CreativeFileType
					,CreativeRepository
					,CreativeAssetName
					,0
					,----Hard Coded Value
					AdFormatID
				FROM [dbo].[CreativeDetailODR]
				WHERE [dbo].[CreativeDetailODR].CreativeMasterID = @CreativeMasterId

				--Updating [OccurrenceDetailsODR]
				--Update [dbo].[OccurrenceDetailODR] Set [PatternID]=Null,[AdID]=Null Where [dbo].[OccurrenceDetailODR].[PatternID]=@Patternmasterid L.E 1.31.17
				UPDATE [dbo].[OccurrenceDetailODR]
				SET [AdID] = NULL
				WHERE [dbo].[OccurrenceDetailODR].[PatternID] = @Patternmasterid

				-- Deleting PatternMaster and Creativemaster
				--L.E. on 1/31/2017 Delete from [Pattern] where [Pattern].[PatternID]=@Patternmasterid
				UPDATE [Pattern]
				SET AdID = NULL
				WHERE [Pattern].[PatternID] = @Patternmasterid

				DELETE
				FROM [Creative]
				WHERE [Creative].PK_Id = @CreativeMasterId
			END

			-- Television
			IF (@MediaStreamValue = 'TV')
			BEGIN
				--Getting OccurrenceId
				SET @OccurrenceId = (
						SELECT [Creative].[SourceOccurrenceId]
						FROM [dbo].[Creative]
						INNER JOIN [Pattern] ON [Creative].pk_id = [Pattern].[CreativeID]
							AND [Pattern].[PatternID] = @Patternmasterid
						)

				-- Geeting CreativeMasterId and CreativeSignature From Patternmaster
				SELECT @CreativeMasterId = [CreativeID]
					,@CreativeSignature = CreativeSignature
				FROM [Pattern]
				WHERE [Pattern].[PatternID] = @Patternmasterid

				INSERT INTO [CreativeStaging] (
					Deleted
					,[CreatedDT]
					,[OccurrenceID]
					)
				VALUES (
					0
					,getdate()
					,@OccurrenceId
					)

				SET @CreativeStgId = Scope_identity();

				-- Move Records in PatternMaster to [dbo].[PatternMasterStgTV] 
				INSERT INTO [dbo].[PatternStaging] (
					[CreativeStgId]
					,[CreativeSignature]
					,[LanguageID]
					,AuditedByID
					,AuditedDT
					)
				SELECT @CreativeStgId
					,@CreativeSignature
					,@Language
					,@UserId
					,Getdate()
				FROM [Pattern]
				WHERE [Pattern].[PatternID] = @Patternmasterid

				SET @PatternStgId = Scope_identity();

				--Move Records in [CreativeDetailTV] to [CreativeDetailsODRStg]
				INSERT INTO [dbo].[CreativeDetailStagingTV] (
					[CreativeStgMasterID]
					,[OccurrenceID]
					,[MediaFormat]
					,[MediaFilepath]
					,[MediaFileName]
					,[FileSize]
					)
				SELECT @CreativeStgId
					,@OccurrenceId
					,CreativeFileType
					,CreativeRepository
					,CreativeAssetName
					,0 ----Hard Coded Value
				FROM [dbo].[CreativeDetailTV]
				WHERE [dbo].[CreativeDetailTV].CreativeMasterID = @CreativeMasterId

				--Updating [OccrncDetailsTV]
				UPDATE [dbo].[OccurrenceDetailTV]
				SET [AdID] = NULL
				WHERE [dbo].[OccurrenceDetailTV].[PatternID] = @Patternmasterid

				UPDATE [Pattern]
				SET AdID = NULL
				WHERE [Pattern].[PatternID] = @Patternmasterid

				-- Deleting PatternMaster and Creativemaster
				--Delete from [Pattern] where [Pattern].[PatternID]=@Patternmasterid
				DELETE
				FROM [Creative]
				WHERE [Creative].PK_Id = @CreativeMasterId
			END

			-- Cinema
			IF (@MediaStreamValue = 'CIN')
			BEGIN
				--Getting OccurrenceId
				SET @OccurrenceId = (
						SELECT [Creative].[SourceOccurrenceId]
						FROM [dbo].[Creative]
						INNER JOIN [Pattern] ON [Creative].pk_id = [Pattern].[CreativeID]
							AND [Pattern].[PatternID] = @Patternmasterid
						)

				-- Geeting CreativeMasterId and CreativeSignature From Patternmaster
				SELECT @CreativeMasterId = [CreativeID]
					,@CreativeSignature = CreativeSignature
				FROM [Pattern]
				WHERE [Pattern].[PatternID] = @Patternmasterid

				INSERT INTO [CreativeStaging] (
					Deleted
					,[CreatedDT]
					,[OccurrenceID]
					)
				VALUES (
					0
					,getdate()
					,@OccurrenceId
					)

				SET @CreativeStgId = Scope_identity();

				-- Move Records in PatternMaster to [dbo].[PatternMasterStgCIN]
				INSERT INTO [dbo].[PatternStaging] (
					PatternID
					,[CreativeStgID]
					,[CreativeSignature]
					,[LanguageID]
					,[CreatedDT]
					,[CreatedByID]
					,[AuditedByID]
					,[AuditedDT]
					)
				SELECT Patternid
					,@CreativeStgId
					,@CreativeSignature
					,@Language
					,getdate()
					,@UserId
					,@UserId
					,getdate()
				FROM [Pattern]
				WHERE [Pattern].[PatternID] = @Patternmasterid

				SET @PatternStgId = Scope_identity();

				--Move Records in [dbo].[CreativeDetailCIN] to [dbo].[CreativeDetailsCINStg]
				INSERT INTO [dbo].[CreativeDetailStagingCIN] (
					[CreativeStagingID]
					,[CreativeFileType]
					,[CreativeRepository]
					,[CreativeAssetName]
					,[CreativeFileSize]
					)
				SELECT @CreativeStgId
					,CreativeFileType
					,CreativeRepository
					,CreativeAssetName
					,0 ----Hard Coded Value
				FROM [dbo].[CreativeDetailCIN]
				WHERE [dbo].[CreativeDetailCIN].[CreativeMasterID] = @CreativeMasterId

				--Updating [dbo].[OccurrenceDetailsCIN]
				UPDATE [dbo].[OccurrenceDetailCIN]
				SET [AdID] = NULL
				WHERE [dbo].[OccurrenceDetailCIN].[PatternID] = @Patternmasterid

				-- Deleting PatternMaster and Creativemaster
				UPDATE [Pattern]
				SET AdID = NULL
				WHERE [Pattern].[PatternID] = @Patternmasterid

				--Delete from [Pattern] where [Pattern].[PatternID]=@Patternmasterid
				DELETE
				FROM [Creative]
				WHERE [Creative].PK_Id = @CreativeMasterId
			END

			-- Online Display
			IF (@MediaStreamValue = 'OND')
			BEGIN
				--Getting OccurrenceId
				SET @OccurrenceId = (
						SELECT [Creative].[SourceOccurrenceId]
						FROM [dbo].[Creative]
						INNER JOIN [Pattern] ON [Creative].pk_id = [Pattern].[CreativeID]
							AND [Pattern].[PatternID] = @Patternmasterid
						)

				-- Geeting CreativeMasterId and CreativeSignature From Patternmaster
				SELECT @CreativeMasterId = [CreativeID]
					,@CreativeSignature = CreativeSignature
				FROM [Pattern]
				WHERE [Pattern].[PatternID] = @Patternmasterid

				INSERT INTO [CreativeStaging] (
					Deleted
					,[CreatedDT]
					,[OccurrenceID]
					,CreativeSignature
					)
				VALUES (
					0
					,getdate()
					,@OccurrenceId
					,@CreativeSignature
					)

				SET @CreativeStgId = Scope_identity();

				-- Move Records in PatternMaster to PatternMasterStg
				INSERT INTO [PatternStaging] (
					PatternID
					,[CreativeStgID]
					,[Priority]
					,[MediaStream]
					,[Status]
					,[AutoIndexing]
					,[CreativeIdAcIdUseCase]
					,[LanguageID]
					,[CreatedDT]
					,[CreatedByID]
					,WorkType
					,[AuditedByID]
					,[AuditedDT]
					)
				SELECT PatternId
					,@CreativeStgId
					,[Priority]
					,@MediaStreamId
					,[Status]
					,0
					,--Hard Coded Value
					'NN'
					,--Hard Coded Value
					@Language
					,getdate()
					,@UserId
					,1
					,@UserId
					,getdate() --Hard Coded Value
				FROM [Pattern]
				WHERE [Pattern].[PatternID] = @Patternmasterid

				SET @PatternStgId = Scope_identity();

				--Inserting OccurrenceDetailsond 
				-- INSERT INTO  occurrencedetailsond(FK_PatternMasterStagingID,CreativeSignature,CreateDTM)
				--VALUES(@PatternStgId,@CreativeSignature,getdate())
				--Move Records in CreativeDetailOND to CreativeDetailStagingOND
				--MediaIrisCreativeID,CreativeDownloaded,LandingPageDownloaded,SignatureDefault,CreateDTM,FK_SourceUrlID
				INSERT INTO CreativeDetailStagingOND (
					CreativeStagingID
					,CreativeFileType
					,CreativeRepository
					,CreativeAssetName
					,FileSize
					,MediaIrisCreativeID
					,CreativeDownloaded
					,LandingPageDownloaded
					,SignatureDefault
					,[CreatedDT]
					,[SourceUrlID]
					)
				SELECT @CreativeStgId
					,CreativeFileType
					,CreativeRepository
					,CreativeAssetName
					,CreativeFileSize
					,----Hard Coded Value
					- 1
					,1
					,0
					,substring(CreativeAssetName, 0, CHARINDEX('.', CreativeAssetName))
					,getdate()
					,- 1
				FROM CreativeDetailOND
				WHERE CreativeDetailOND.[CreativeMasterID] = @CreativeMasterId

				--Print('--Inserted--')
				--Updating OccurrenceDetailsOND
				UPDATE [OccurrenceDetailOND]
				SET [AdID] = NULL
					,[PatternStagingID] = @PatternStgId
				WHERE [OccurrenceDetailOND].[PatternID] = @Patternmasterid

				UPDATE [Pattern]
				SET AdID = NULL
				WHERE [Pattern].[PatternID] = @Patternmasterid

				-- Deleting Creativedetailond,Creativemaster and PatternMaster  
				DELETE
				FROM Creativedetailond
				WHERE [CreativeMasterID] = @CreativeMasterId

				DELETE
				FROM [Creative]
				WHERE [Creative].PK_Id = @CreativeMasterId
					--DELETE FROM [Pattern] WHERE [Pattern].[PatternID]=@Patternmasterid
			END

			IF (@MediaStreamValue = 'ONV') --Online Video
			BEGIN
				--Getting OccurrenceId
				SET @OccurrenceId = (
						SELECT [Creative].[SourceOccurrenceId]
						FROM [dbo].[Creative]
						INNER JOIN [Pattern] ON [Creative].pk_id = [Pattern].[CreativeID]
							AND [Pattern].[PatternID] = @Patternmasterid
						)

				-- Getting CreativeMasterId and CreativeSignature From Patternmaster
				SELECT @CreativeMasterId = [CreativeID]
					,@CreativeSignature = CreativeSignature
				FROM [Pattern]
				WHERE [Pattern].[PatternID] = @Patternmasterid

				INSERT INTO [CreativeStaging] (
					Deleted
					,[CreatedDT]
					,[OccurrenceID]
					,CreativeSignature
					)
				VALUES (
					0
					,getdate()
					,@OccurrenceId
					,@CreativeSignature
					)

				SET @CreativeStgId = Scope_identity();

				-- Move Records in PatternMaster to PatternMasterStg
				INSERT INTO [PatternStaging] (
					PatternID
					,[CreativeStgID]
					,[Priority]
					,[MediaStream]
					,[Status]
					,[AutoIndexing]
					,[CreativeIdAcIdUseCase]
					,[LanguageID]
					,[CreatedDT]
					,[CreatedByID]
					,WorkType
					,[AuditedByID]
					,[AuditedDT]
					)
				SELECT PatternId
					,@CreativeStgId
					,[Priority]
					,@MediaStreamId
					,[Status]
					,0
					,--Hard Coded Value
					'NN'
					,--Hard Coded Value
					@Language
					,getdate()
					,@UserId
					,1
					,@UserId
					,getdate() --Hard Coded Value
				FROM [Pattern]
				WHERE [Pattern].[PatternID] = @Patternmasterid

				SET @PatternStgId = Scope_identity();

				--Move Records in CreativeDetailsONV to CreativeDetailStagingONV
				INSERT INTO CreativeDetailStagingONV (
					CreativeStagingID
					,SourceUrlID
					,MediaIrisCreativeID
					,CreativeFileType
					,CreativeRepository
					,CreativeAssetName
					,FileSize
					,Duration
					,CreativeDownloaded
					,LandingPageDownloaded
					,SignatureDefault
					,[CreatedDT]
					)
				SELECT @CreativeStgId
					,- 1
					,- 1
					,CreativeFileType
					,CreativeRepository
					,CreativeAssetName
					,CreativeFileSize
					,0
					,1
					,0
					,substring(CreativeAssetName, 0, CHARINDEX('.', CreativeAssetName))
					,getdate()
				FROM CreativeDetailONV
				WHERE CreativeDetailONV.[CreativeMasterID] = @CreativeMasterId

				--Print('--Inserted--')
				--Updating OccurrenceDetailsONv
				UPDATE [OccurrenceDetailONV]
				SET [AdID] = NULL
					,[PatternStagingID] = @PatternStgId
				WHERE [OccurrenceDetailONV].[PatternID] = @Patternmasterid

				UPDATE [Pattern]
				SET AdID = NULL
				WHERE [Pattern].[PatternID] = @Patternmasterid

				-- Deleting Creativedetailonv,Creativemaster and PatternMaster  
				DELETE
				FROM Creativedetailonv
				WHERE [CreativeMasterID] = @CreativeMasterId

				DELETE
				FROM [Creative]
				WHERE [Creative].PK_Id = @CreativeMasterId
					--DELETE FROM [Pattern] WHERE [Pattern].[PatternID]=@Patternmasterid
			END

			IF (@MediaStreamValue = 'MOB')
			BEGIN
				--Getting OccurrenceId
				SET @OccurrenceId = (
						SELECT [Creative].[SourceOccurrenceId]
						FROM [dbo].[Creative]
						INNER JOIN [Pattern] ON [Creative].pk_id = [Pattern].[CreativeID]
							AND [Pattern].[PatternID] = @Patternmasterid
						)

				-- Getting CreativeMasterId and CreativeSignature From Patternmaster
				SELECT @CreativeMasterId = [CreativeID]
					,@CreativeSignature = CreativeSignature
				FROM [Pattern]
				WHERE [Pattern].[PatternID] = @Patternmasterid

				INSERT INTO [CreativeStaging] (
					Deleted
					,[CreatedDT]
					,[OccurrenceID]
					,CreativeSignature
					)
				VALUES (
					0
					,getdate()
					,@OccurrenceId
					,@CreativeSignature
					)

				SET @CreativeStgId = Scope_identity();

				-- Move Records in PatternMaster to PatternMasterStg
				INSERT INTO [PatternStaging] (
					PatternID
					,[CreativeStgID]
					,[Priority]
					,[MediaStream]
					,[Status]
					,[AutoIndexing]
					,[CreativeIdAcIdUseCase]
					,[LanguageID]
					,[CreatedDT]
					,[CreatedByID]
					,WorkType
					,[AuditedByID]
					,[AuditedDT]
					)
				SELECT PatternId
					,@CreativeStgId
					,[Priority]
					,@MediaStreamId
					,[Status]
					,0
					,--Hard Coded Value
					'NN'
					,--Hard Coded Value
					@Language
					,getdate()
					,@UserId
					,1
					,@UserId
					,getdate() --Hard Coded Value
				FROM [Pattern]
				WHERE [Pattern].[PatternID] = @Patternmasterid

				SET @PatternStgId = Scope_identity();

				--Move Records in CreativeDetailsMOB to CreativeDetailStagingMOB
				INSERT INTO CreativeDetailStagingMOB (
					CreativeStagingID
					,[SourceUrlID]
					,MediaIrisCreativeID
					,CreativeFileType
					,CreativeRepository
					,CreativeAssetName
					,FileSize
					,Duration
					,CreativeDownloaded
					,LandingPageDownloaded
					,SignatureDefault
					,[CreatedDT]
					)
				SELECT @CreativeStgId
					,- 1
					,- 1
					,CreativeFileType
					,CreativeRepository
					,CreativeAssetName
					,CreativeFileSize
					,0
					,1
					,0
					,substring(CreativeAssetName, 0, CHARINDEX('.', CreativeAssetName))
					,getdate()
				FROM CreativeDetailMOB
				WHERE CreativeDetailMOB.[CreativeMasterID] = @CreativeMasterId

				--Print('--Inserted--')
				--Updating OccurrenceDetailsOND
				UPDATE [OccurrenceDetailMOB]
				SET [AdID] = NULL
					,[PatternStagingID] = @PatternStgId
				WHERE [OccurrenceDetailMOB].[PatternID] = @Patternmasterid

				UPDATE [Pattern]
				SET AdID = NULL
				WHERE [Pattern].[PatternID] = @Patternmasterid

				-- Deleting Creativedetailmob,Creativemaster and PatternMaster  
				DELETE
				FROM Creativedetailmob
				WHERE [CreativeMasterID] = @CreativeMasterId

				DELETE
				FROM [Creative]
				WHERE [Creative].PK_Id = @CreativeMasterId
					--DELETE FROM [Pattern] WHERE [Pattern].[PatternID]=@Patternmasterid
			END

			IF @PatternCount = 1 AND @DeleteOrphanAd = 1
			BEGIN
				UPDATE Ad SET Valid = 0 WHERE AdId = @AdId
			END

			SELECT 1 AS result

			COMMIT TRANSACTION
		END
	END TRY

	BEGIN CATCH
		DECLARE @error INT
			,@message VARCHAR(4000)
			,@lineNo INT

		SELECT @error = Error_number()
			,@message = Error_message()
			,@lineNo = Error_line()

		RAISERROR (
				'sp_ReviewQueueUpdatePattermasterMoveData: %d: %s'
				,16
				,1
				,@error
				,@message
				,@lineNo
				);

		ROLLBACK TRANSACTION
	END CATCH
END