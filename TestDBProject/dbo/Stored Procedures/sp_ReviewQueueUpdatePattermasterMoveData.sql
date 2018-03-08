

-- ============================================================================================================
-- Author		:	Karunakar
-- Create date	:	2nd September 2015
-- Description	:	This Procedure is Used to Perform QC NoTake 
--					1.Moving Data from Child tables to staging tables 
-- Execution	:   sp_ReviewQueueUpdatePattermasterMoveData 6415,144,29712040
-- Updated By	:	Ramesh Bangi for Online Display on 09/25/2015
--				:	Karunakar on 13th October 2015,Adding Mobile and Online Video Media Streams.
--					Arun Nair on 11/24/2015 - Added Auditby/On on Staging Tables for all MediaStream
-- ==============================================================================================================
CREATE PROCEDURE [dbo].[sp_ReviewQueueUpdatePattermasterMoveData] 
	@Patternmasterid As Int,
	@MediaStreamId As Int,
	@UserId As Int
AS
BEGIN
	
	SET NOCOUNT ON;
    BEGIN TRY
				BEGIN TRANSACTION 
				Declare @CreativeSignature As Nvarchar(max)=''
				Declare @CreativeMasterId As Int
				Declare @OccurrenceId as BigInt
				Declare @CreativeStgId As Int
				Declare @LanguageId As Int=1  --Hard Coded Value -- Language English
				Declare @PatternStgId As Int
				Declare @MediaStreamValue As Nvarchar(max)=''
				Declare @MediaStream As Nvarchar(max)=''

				Declare @CreativemasterStgId as int=0

				Select @MediaStreamValue=Value,@MediaStream=ValueTitle  from   [dbo].[Configuration] Where ConfigurationID=@MediaStreamId

				-- Radio
				IF(@MediaStreamValue='RAD')
				BEGIN
								--Getting OccurrenceId
								Set @OccurrenceId=(Select [Creative].[SourceOccurrenceId] from [dbo].[Creative] 
													inner join [Pattern] on [Creative].pk_id=[Pattern].[CreativeID] 
													and [Pattern].[PatternID]=@Patternmasterid)

								-- Geeting CreativeMasterId and CreativeSignature From Patternmaster
								Select @CreativeMasterId=[CreativeID],@CreativeSignature=CreativeSignature from [Pattern] Where [Pattern].[PatternID]=@Patternmasterid

								Insert into [CreativeStaging] (Deleted,[CreatedDT],[OccurrenceID]) Values (0,getdate(),@OccurrenceId)
								Set @CreativeStgId=Scope_identity(); 

								-- Move Records in PatternMaster to PatternMasterStg
								Insert into [PatternStaging]
								(PatternId,
								[CreativeStgID],
								[Priority],
								[MediaStream],
								[Status],
								[AutoIndexing],
								[CreativeIdAcIdUseCase],
								[LanguageID],
								[CreatedDT],
								[CreatedByID],
								[AuditedByID],
								[AuditedDT]
								)
								Select 
								Patternid,
								@CreativeStgId,
								[Priority],
								@MediaStreamValue,
								[Status],
								0,			--Hard Coded Value
								'NN',		--Hard Coded Value
								@LanguageId,
								getdate(),
								@UserId,
								@UserId,
								getdate()
								From [Pattern] Where [Pattern].[PatternID]=@Patternmasterid
								Set @PatternStgId=Scope_identity(); 

								--Inserting PatternDetailRAStg 
								insert into PatternDetailRAStg([PatternStgID],[RCSCreativeID],[CreatedDT],[CreatedByID])
								 Values(@PatternStgId,@CreativeSignature,getdate(),@UserId)

								--Move Records in CreativeDetailsRA to CreativeDetailsRAStg

								Insert into [CreativeDetailStagingRA]
								(
								[CreativeStgID],
								[MediaFormat],
								[MediaFilePath],
								[MediaFileName],
								[FileSize])
								Select 
								@CreativeStgId,
								[FileTYpe],
								[Rep],
								[AssetName],
								0  ----Hard Coded Value
								From [CreativeDetailRA] where [CreativeDetailRA].[CreativeID]=@CreativeMasterId
								Print('--Inserted--')
								--Updating OccrncDetailsRA
								--Update [OccurrenceDetailRA] Set [PatternID]=Null Where [OccurrenceDetailRA].[PatternID]=@Patternmasterid

								-- Updating Patternmaster No Take Reason
								Update  [Pattern] Set  NoTakeReasonCode=Null  Where [Pattern].[PatternID]=@Patternmasterid

								-- Deleting PatternMaster and Creativemaster

								--Delete from [Pattern] where [Pattern].[PatternID]=@Patternmasterid
								--Delete from PatternDetailRA where [RCSCreativeID]=@CreativeSignature
								Delete from [Creative] Where [Creative].PK_Id=@CreativeMasterId
								
								--Updating RCSCreatives
								update [RCSCreative] set [Deleted]=0 where [RCSCreativeID]=@CreativeSignature

								Select @PatternStgId As PatternMasterStgId
				END

				-- Outdoor
				IF(@MediaStreamValue='OD')
				BEGIN
								--Getting OccurrenceId

								Set @OccurrenceId=(Select [Creative].[SourceOccurrenceId] from [dbo].[Creative] 
													inner join [Pattern] on [Creative].pk_id=[Pattern].[CreativeID] 
													and [Pattern].[PatternID]=@Patternmasterid)
								

								-- Geeting CreativeMasterId and CreativeSignature From Patternmaster
								Select @CreativeMasterId=[CreativeID],@CreativeSignature=CreativeSignature from [Pattern] Where [Pattern].[PatternID]=@Patternmasterid

								Insert into [CreativeStaging] (Deleted,[CreatedDT],[OccurrenceID]) Values (0,getdate(),@OccurrenceId)
								Set @CreativeStgId=Scope_identity(); 

								-- Move Records in [dbo].[PatternMaster] to PatternMasterStagingODR
								Insert into [dbo].[PatternStaging]
								(patternid,
								[CreativeStgID],
								[CreativeSignature],
								[LanguageID],
								[CreatedDT],
								[CreatedByID],
								[AuditedByID],
								[AuditedDT]
								)
								Select 
								patternid,
								@CreativeStgId,
								@CreativeSignature,							
								@LanguageId,
								getdate(),
								@UserId,
								@UserId,
								getdate()
								From [Pattern] Where [Pattern].[PatternID]=@Patternmasterid
								Set @PatternStgId=Scope_identity(); 
								
								--Move Records in [CreativeDetailODR] to [CreativeDetailsODRStg]
								Insert into [dbo].[CreativeDetailStagingODR]
								(
								CreativeStagingID,
								CreativeFileType,
								CreativeRepository,
								CreativeAssetName,
								CreativeFileSize,
								AdFormatId)
								Select 
								@CreativeStgId,
								CreativeFileType,
								CreativeRepository,
								CreativeAssetName,
								0,				----Hard Coded Value
								AdFormatID
								From [dbo].[CreativeDetailODR] where [dbo].[CreativeDetailODR].CreativeMasterID=@CreativeMasterId
				
								--Updating [OccurrenceDetailsODR]
								--Update [dbo].[OccurrenceDetailODR] Set [PatternID]=Null Where [dbo].[OccurrenceDetailODR] .[PatternID]=@Patternmasterid
								
								-- Updating Patternmaster No Take Reason
								Update  [Pattern] Set  NoTakeReasonCode=Null  Where [Pattern].[PatternID]=@Patternmasterid

								-- Deleting PatternMaster and Creativemaster

								--Delete from [Pattern] where [Pattern].[PatternID]=@Patternmasterid
								Delete from [Creative] Where [Creative].PK_Id=@CreativeMasterId

								Select @PatternStgId As PatternMasterStgId
				END

				-- Television
				IF(@MediaStreamValue='TV')
				BEGIN
								--Getting OccurrenceId
								Set @OccurrenceId=(Select [Creative].[SourceOccurrenceId] from [dbo].[Creative] 
													inner join [Pattern] on [Creative].pk_id=[Pattern].[CreativeID] 
													and [Pattern].[PatternID]=@Patternmasterid)

								-- Geeting CreativeMasterId and CreativeSignature From Patternmaster
								Select @CreativeMasterId=[CreativeID],@CreativeSignature=CreativeSignature from [Pattern] Where [Pattern].[PatternID]=@Patternmasterid

								Insert into [CreativeStaging] (Deleted,[CreatedDT],[OccurrenceID]) Values (0,getdate(),@OccurrenceId)
								Set @CreativeStgId=Scope_identity();
								 
								Print(@OccurrenceId)

								Print(@CreativeStgId)

								-- Move Records in PatternMaster to [dbo].[PatternMasterStgTV] 
								Insert into [dbo].[PatternTVStg]
								(
								[CreativeStgID],
								[CreativeSignature],
								[LanguageID],
								AuditBy,
								AuditDTM
								)
								Select 
								@CreativeStgId,
								@CreativeSignature,							
								@LanguageId,
								@Userid,
								getdate()
								From [Pattern] Where [Pattern].[PatternID]=@Patternmasterid
								Set @PatternStgId=Scope_identity(); 

								Print(@PatternStgId)
								
								--Move Records in [CreativeDetailTV] to [CreativeDetailTVStg]
								Insert into [dbo].[CreativeDetailStagingTV]
								(
								[CreativeStgMasterID],
								[OccurrenceID],
								[MediaFormat],
								[MediaFilepath],
								[MediaFileName],
								[FileSize]
								)
								Select 
								@CreativeStgId,
								@OccurrenceId,
								CreativeFileType,
								CreativeRepository,
								CreativeAssetName,
								0				----Hard Coded Value
								From [dbo].[CreativeDetailTV] where [dbo].[CreativeDetailTV].CreativeMasterID=@CreativeMasterId
								Set @CreativemasterStgId=Scope_identity();

								Print(@CreativemasterStgId)

								--Updating [OccrncDetailsTV]
								--Update [dbo].[OccurrenceDetailTV] Set [PatternID]=Null Where [dbo].[OccurrenceDetailTV].[PatternID]=@Patternmasterid

								-- Updating Patternmaster No Take Reason
								Update  [Pattern] Set  NoTakeReasonCode=Null  Where [Pattern].[PatternID]=@Patternmasterid

								-- Deleting PatternMaster and Creativemaster

								--Delete from [Pattern] where [Pattern].[PatternID]=@Patternmasterid

								Delete from [Creative] Where [Creative].PK_Id=@CreativeMasterId

								Select @PatternStgId As PatternMasterStgId
				END
				
				-- Cinema
				IF(@MediaStreamValue='CIN')
				BEGIN
								--Getting OccurrenceId
								Set @OccurrenceId=(Select [Creative].[SourceOccurrenceId] from [dbo].[Creative] 
													inner join [Pattern] on [Creative].pk_id=[Pattern].[CreativeID] 
													and [Pattern].[PatternID]=@Patternmasterid)


								-- Geeting CreativeMasterId and CreativeSignature From Patternmaster
								Select @CreativeMasterId=[CreativeID],@CreativeSignature=CreativeSignature from [Pattern] Where [Pattern].[PatternID]=@Patternmasterid

								Insert into [CreativeStaging] (Deleted,[CreatedDT],[OccurrenceID]) Values (0,getdate(),@OccurrenceId)
								Set @CreativeStgId=Scope_identity(); 

								-- Move Records in PatternMaster to [dbo].[PatternMasterStgCIN]
								Insert into [dbo].[PatternStaging]
								(PatternID,
								[CreativeStgID],
								[CreativeSignature],
								[LanguageID],
								[CreatedDT],
								[CreatedByID],
								AuditedByID,
								AuditedDT
								)
								Select 
								Patternid,
								@CreativeStgId,
								@CreativeSignature,							
								@LanguageId,
								getdate(),
								@UserId,
								@UserId,
								getdate()
								From [Pattern] Where [Pattern].[PatternID]=@Patternmasterid
								Set @PatternStgId=Scope_identity(); 
								
								--Move Records in [dbo].[CreativeDetailCIN] to [dbo].[CreativeDetailsCINStg]
								Insert into [dbo].[CreativeDetailStagingCIN]
								(
								[CreativeStagingID],
								[CreativeFileType],
								[CreativeRepository],
								[CreativeAssetName],
								[CreativeFileSize]
								)
								Select 
								@CreativeStgId,
								CreativeFileType,
								CreativeRepository,
								CreativeAssetName,
								0				----Hard Coded Value
								From [dbo].[CreativeDetailCIN] where [dbo].[CreativeDetailCIN].[CreativeMasterID]=@CreativeMasterId
				
								--Updating [dbo].[OccurrenceDetailsCIN]
								--Update [dbo].[OccurrenceDetailCIN] Set [PatternID]=Null Where [dbo].[OccurrenceDetailCIN].[PatternID]=@Patternmasterid
								
								-- Updating Patternmaster No Take Reason
								Update  [Pattern] Set  NoTakeReasonCode=Null  Where [Pattern].[PatternID]=@Patternmasterid

								-- Deleting PatternMaster and Creativemaster

								--Delete from [Pattern] where [Pattern].[PatternID]=@Patternmasterid
								Delete from [Creative] Where [Creative].PK_Id=@CreativeMasterId

								Select @PatternStgId As PatternMasterStgId
				END

				
				IF(@MediaStreamValue='OND')   --Online Display
				BEGIN 
								--Getting OccurrenceId
								Set @OccurrenceId=(Select [Creative].[SourceOccurrenceId] from [dbo].[Creative] 
													inner join [Pattern] on [Creative].pk_id=[Pattern].[CreativeID] 
													and [Pattern].[PatternID]=@Patternmasterid)

								-- Getting CreativeMasterId and CreativeSignature From Patternmaster
								Select @CreativeMasterId=[CreativeID],@CreativeSignature=CreativeSignature from [Pattern] Where [Pattern].[PatternID]=@Patternmasterid

								Insert into [CreativeStaging] (Deleted,[CreatedDT],[OccurrenceID],CreativeSignature) Values (0,getdate(),@OccurrenceId,@CreativeSignature)
								Set @CreativeStgId=Scope_identity(); 

								-- Move Records in PatternMaster to PatternMasterStg
								Insert into [PatternStaging]
								(PatternID,
								[CreativeStgID],
								[Priority],
								[MediaStream],
								[Status],
								[AutoIndexing],
								[CreativeIdAcIdUseCase],
								[LanguageID],
								[CreatedDT],
								[CreatedByID],
								WorkType,
								[AuditedByID],
								[AuditedDT]
								)
								Select 
								Patternid,
								@CreativeStgId,
								[Priority],
								@MediaStreamId,
								[Status],
								0,			--Hard Coded Value
								'NN',		--Hard Coded Value
								@LanguageId,
								getdate(),
								@UserId,
								1,@UserId,getdate()--Hard Coded Value
								From [Pattern] Where [Pattern].[PatternID]=@Patternmasterid
								Set @PatternStgId=Scope_identity(); 

								--Inserting CccurrenceDetailsond 

								 -- insert into  occurrencedetailsond(FK_PatternMasterStagingID,CreativeSignature,CreateDTM)
								  --Values(@PatternStgId,@CreativeSignature,getdate())

								--Move Records in CreativeDetailOND to CreativeDetailStagingOND

								INSERT INTO CreativeDetailStagingOND
								(
								CreativeStagingID,
								CreativeFileType,
								CreativeRepository,
								CreativeAssetName,
								FileSize,		
								MediaIrisCreativeID,
								CreativeDownloaded,
								LandingPageDownloaded,
								SignatureDefault,
								[CreatedDT],
								[SourceUrlID])

								SELECT 
								@CreativeStgId,
								CreativeFileType,
								CreativeRepository,
								CreativeAssetName,
								CreativeFileSize,  ----Hard Coded Value
								-1,
								1,
								0,
								substring(CreativeAssetName,0,CHARINDEX('.', CreativeAssetName)),
								getdate(),
								-1
								FROM CreativeDetailOND WHERE CreativeDetailOND.[CreativeMasterID]=@CreativeMasterId
								--Print('--Inserted--')
								--Updating occurrencedetailsond
								Update [OccurrenceDetailOND] Set [PatternStagingID]=@PatternStgId Where [PatternID]=@Patternmasterid

								-- Updating Patternmaster No Take Reason
								Update  [Pattern] Set  NoTakeReasonCode=Null  Where [Pattern].[PatternID]=@Patternmasterid

								-- Deleting Creativedetailond,Creativemaster and PatternMaster  
								Delete from  Creativedetailond where [CreativeMasterID]=@CreativeMasterId
								DELETE FROM [Creative] WHERE [Creative].PK_Id=@CreativeMasterId
								--DELETE FROM [Pattern] WHERE [Pattern].[PatternID]=@Patternmasterid

								Select @PatternStgId As PatternMasterStgId
				END
				IF(@MediaStreamValue='ONV')		--Online Video
				BEGIN 
								--Getting OccurrenceId
								Set @OccurrenceId=(Select [Creative].[SourceOccurrenceId] from [dbo].[Creative] 
													inner join [Pattern] on [Creative].pk_id=[Pattern].[CreativeID] 
													and [Pattern].[PatternID]=@Patternmasterid)

								-- Getting CreativeMasterId and CreativeSignature From Patternmaster
								Select @CreativeMasterId=[CreativeID],@CreativeSignature=CreativeSignature from [Pattern] Where [Pattern].[PatternID]=@Patternmasterid

								Insert into [CreativeStaging] (Deleted,[CreatedDT],[OccurrenceID],CreativeSignature) Values (0,getdate(),@OccurrenceId,@CreativeSignature)
								Set @CreativeStgId=Scope_identity(); 

								-- Move Records in PatternMaster to PatternMasterStg
								Insert into [PatternStaging]
								(PatternID,
								[CreativeStgID],
								[Priority],
								[MediaStream],
								[Status],
								[AutoIndexing],
								[CreativeIdAcIdUseCase],
								[LanguageID],
								[CreatedDT],
								[CreatedByID],
								WorkType,
								[AuditedByID],
								[AuditedDT]
								)
								Select 
								PatternId,
								@CreativeStgId,
								[Priority],
								@MediaStreamId,
								[Status],
								0,			--Hard Coded Value
								'NN',		--Hard Coded Value
								@LanguageId,
								getdate(),
								@UserId,
								1,@UserId,getdate() --Hard Coded Value
								From [Pattern] Where [Pattern].[PatternID]=@Patternmasterid
								Set @PatternStgId=Scope_identity(); 

								

								--Move Records in CreativeDetailsONV to CreativeDetailStagingONV

								INSERT INTO CreativeDetailStagingONV
								(
								CreativeStagingID,
								SourceUrlID,
								MediaIrisCreativeID,
								CreativeFileType,
								CreativeRepository,
								CreativeAssetName,
								FileSize,
								Duration,										
								CreativeDownloaded,
								LandingPageDownloaded,
								SignatureDefault,
								[CreatedDT]
								)
								SELECT 
								@CreativeStgId,
								-1,
								-1,
								CreativeFileType,
								CreativeRepository,
								CreativeAssetName,
								CreativeFileSize, 
								0,								
								1,
								0,
								substring(CreativeAssetName,0,CHARINDEX('.', CreativeAssetName)),
								getdate()
	
								FROM CreativeDetailONV WHERE CreativeDetailONV.[CreativeMasterID]=@CreativeMasterId
								--Print('--Inserted--')
								--Updating occurrencedetailsonv
								Update [OccurrenceDetailONV] Set [PatternStagingID]=@PatternStgId Where [PatternID]=@Patternmasterid

								-- Updating Patternmaster No Take Reason
								Update  [Pattern] Set  NoTakeReasonCode=Null  Where [Pattern].[PatternID]=@Patternmasterid

								-- Deleting Creativedetailonv,Creativemaster and PatternMaster  
								Delete from  Creativedetailonv where [CreativeMasterID]=@CreativeMasterId
								DELETE FROM [Creative] WHERE [Creative].PK_Id=@CreativeMasterId
								--DELETE FROM [Pattern] WHERE [Pattern].[PatternID]=@Patternmasterid

								Select @PatternStgId As PatternMasterStgId
				END

				IF(@MediaStreamValue='MOB')  --Mobile
				BEGIN 
								--Getting OccurrenceId
								Set @OccurrenceId=(Select [Creative].[SourceOccurrenceId] from [dbo].[Creative] 
													inner join [Pattern] on [Creative].pk_id=[Pattern].[CreativeID] 
													and [Pattern].[PatternID]=@Patternmasterid)

								-- Getting CreativeMasterId and CreativeSignature From Patternmaster
								Select @CreativeMasterId=[CreativeID],@CreativeSignature=CreativeSignature from [Pattern] Where [Pattern].[PatternID]=@Patternmasterid

								Insert into [CreativeStaging] (Deleted,[CreatedDT],[OccurrenceID],CreativeSignature) Values (0,getdate(),@OccurrenceId,@CreativeSignature)
								Set @CreativeStgId=Scope_identity(); 

								-- Move Records in PatternMaster to PatternMasterStg
								Insert into [PatternStaging]
								(PatternID,
								[CreativeStgID],
								[Priority],
								[MediaStream],
								[Status],
								[AutoIndexing],
								[CreativeIdAcIdUseCase],
								[LanguageID],
								[CreatedDT],
								[CreatedByID],
								WorkType,
								[AuditedByID],
								[AuditedDT]
								)
								Select 
								PatternId,
								@CreativeStgId,
								[Priority],
								@MediaStreamId,
								[Status],
								0,			--Hard Coded Value
								'NN',		--Hard Coded Value
								@LanguageId,
								getdate(),
								@UserId,
								1,@UserId,getdate() --Hard Coded Value
								From [Pattern] Where [Pattern].[PatternID]=@Patternmasterid
								Set @PatternStgId=Scope_identity(); 

								

								--Move Records in CreativeDetailsMOB to CreativeDetailStagingMOB

								INSERT INTO CreativeDetailStagingMOB
								(
								CreativeStagingID,
								[SourceUrlID],
								MediaIrisCreativeID,
								CreativeFileType,
								CreativeRepository,
								CreativeAssetName,
								FileSize,
								Duration,										
								CreativeDownloaded,
								LandingPageDownloaded,
								SignatureDefault,
								[CreatedDT]
								)
								SELECT 
								@CreativeStgId,
								-1,
								-1,
								CreativeFileType,
								CreativeRepository,
								CreativeAssetName,
								CreativeFileSize,  ----Hard Coded Value
								0,								
								1,
								0,
								substring(CreativeAssetName,0,CHARINDEX('.', CreativeAssetName)),
								getdate()
	
								FROM CreativeDetailMOB WHERE CreativeDetailMOB.[CreativeMasterID]=@CreativeMasterId
								--Print('--Inserted--')
								--Updating occurrencedetailsMOB
								Update [OccurrenceDetailMOB] Set [PatternStagingID]=@PatternStgId Where [PatternID]=@Patternmasterid

								-- Updating Patternmaster No Take Reason
								Update  [Pattern] Set  NoTakeReasonCode=Null  Where [Pattern].[PatternID]=@Patternmasterid

								-- Deleting Creativedetailmob,Creativemaster and PatternMaster  
								Delete from  Creativedetailmob where [CreativeMasterID]=@CreativeMasterId
								DELETE FROM [Creative] WHERE [Creative].PK_Id=@CreativeMasterId
								--DELETE FROM [Pattern] WHERE [Pattern].[PatternID]=@Patternmasterid
							

								Select @PatternStgId As PatternMasterStgId
				END
			COMMIT TRANSACTION

 	END TRY 
			BEGIN CATCH 
						DECLARE @error   INT,@message VARCHAR(4000), @lineNo  INT 
						SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
						RAISERROR ('sp_ReviewQueueUpdatePattermasterMoveData: %d: %s',16,1,@error,@message,@lineNo);
						ROLLBACK TRANSACTION
			END CATCH 
END