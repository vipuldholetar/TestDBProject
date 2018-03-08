
--===========================================================================================================
-- Author            : Lisa East
-- Create date       : 8/21/2017
-- Description       : UnMap Occurrence back to staging from the Email Review Queue 
-- Execution		 : [dbo].[sp_EmailReviewQueueUnMapOccurrence] 887360, 154, 464655,29712178
-- Updated By		 : 
--===========================================================================================================
CREATE PROCEDURE [dbo].[sp_EmailReviewQueueUnMapOccurrence]

	@Patternmasterid As Int,
	@MediaStreamId As Int,
	@UserId As Int,	
	@Language As Int,
	@Adid As int
AS
BEGIN
	
	SET NOCOUNT ON;
    BEGIN TRY
				 
				DECLARE @CreativeSignature As Nvarchar(max)=''
				DECLARE @CreativeMasterId As Int
				DECLARE @OccurrenceId as BigInt
				DECLARE @CreativeStgId As Int
				DECLARE @PatternStgId As Int				
				DECLARE @PatternCount as Int=0
				DECLARE @isPrimaryOccurrence as Int=0

				Select @PatternCount=count(*) from [Pattern] where [AdID]=@Adid

				
				SELECT @isPrimaryOccurrence= COUNT(*)
				FROM [dbo].[Creative] 
				INNER JOIN [Pattern] on [Creative].pk_id=[Pattern].[CreativeID] 
				INNER JOIN [Ad] ON [Ad].PrimaryOccurrenceID=[Creative].SourceOccurrenceId										
				AND [Pattern].[PatternID]=@Patternmasterid  AND [Ad].AdID=@Adid

				IF @isPrimaryOccurrence=1
				BEGIN
					SELECT 0 AS result
					PRINT 'IS PRIMARY OCCURRENCE'
				END
				--ELSE IF @PatternCount=1
				--BEGIN
				--	SELECT 0 AS result
				--	PRINT 'ONLY ONE OCCURRENCE FOR THE AD'
				--END
				ELSE
				BEGIN
					BEGIN TRANSACTION
						--GET OCCURRENCEID SELECTED FOR UNMAP

						SET  @OccurrenceId=(SELECT TOP 1 [Creative].[SourceOccurrenceId] 
						FROM [dbo].[Creative] 
						INNER JOIN [Pattern] ON [Creative].pk_id=[Pattern].[CreativeID] 
						AND [Pattern].[PatternID]=@Patternmasterid)

						-- GET EXCLUDED OCCURRENCEIDLIST

						SELECT A.OccurrenceID INTO #TEMPOccurrenceList
						FROM [vw_EmailWorkQueueData] A 
						INNER JOIN [vw_EmailWorkQueueData] B
						ON B.[Subject]=A.[Subject] AND A.[AdvertiserID]=B.[AdvertiserID] AND A.[AdDate]=b.[AdDate]
						WHERE B.[OccurrenceID]=@OccurrenceId

						

						WHILE EXISTS (SELECT TOP 1 OccurrenceID FROM #TEMPOccurrenceList)
						BEGIN 
						
							SELECT @Patternmasterid=PatternID
							FROM [OccurrenceDetailEM] 
							WHERE OccurrenceDetailEMID=@OccurrenceId and AdID=@Adid

					-- Geeting CreativeMasterId and CreativeSignature From Patternmaster
							SELECT @CreativeMasterId=[CreativeID],@CreativeSignature=CreativeSignature 
							FROM [Pattern] 
							WHERE [Pattern].[PatternID]=@Patternmasterid

							INSERT INTO [CreativeStaging] (Deleted,[CreatedDT],[OccurrenceID]) 
							VALUES (0,getdate(),@OccurrenceId)
							Set @CreativeStgId=Scope_identity(); 

				--			-- Move Records in [dbo].[PatternMaster] to PatternMasterStagingEM
																																	
							INSERT INTO [dbo].[PatternStaging] ([PatternID],[CreativeStgID],[CreativeSignature],[MediaStream],[LanguageID],[CreatedDT],[status],[CreatedByID],[AuditedByID],[AuditedDT])
							SELECT @Patternmasterid,@CreativeStgId,@CreativeSignature,@MediaStreamId,@Language,getdate(),[status],@UserId,@UserId,Getdate()
							FROM [Pattern] 
							WHERE [Pattern].[PatternID]=@Patternmasterid
							SET @PatternStgId=Scope_identity(); 
								
							--Move Records in [CreativeDetailEM] to [CreativeDetailStagingEM]
							INSERT INTO [dbo].[CreativeDetailStagingEM] (CreativeStagingID,CreativeFileType,CreativeRepository,CreativeAssetName,CreativeFileSize)
							SELECT @CreativeStgId,CreativeFileType,CreativeRepository,CreativeAssetName,0
							FROM [dbo].[CreativeDetailEM] 
							WHERE [dbo].[CreativeDetailEM].CreativeMasterID=@CreativeMasterId
				
							UPDATE [dbo].[OccurrenceDetailEM] SET [AdID]=Null 
							WHERE [dbo].[OccurrenceDetailEM].[PatternID]=@Patternmasterid
											

							-- Deleting Creativemaster nad updating Pattern

							UPDATE [Pattern] set AdID=NULL 
							WHERE [Pattern].[PatternID]=@Patternmasterid

							DELETE FROM [Creative] 
							WHERE [Creative].PK_Id=@CreativeMasterId

						DELETE FROM #TEMPOccurrenceList WHERE OccurrenceID=@OccurrenceId
						SELECT TOP 1 @OccurrenceId=OccurrenceID FROM #TEMPOccurrenceList
						END 
														
								
					SELECT 1 as result
					COMMIT TRANSACTION
				END					

 	END TRY 
			BEGIN CATCH 
						DECLARE @error   INT,@message VARCHAR(4000), @lineNo  INT 
						SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
						RAISERROR ('sp_EmailReviewQueueUnMapOccurrence: %d: %s',16,1,@error,@message,@lineNo);
						ROLLBACK TRANSACTION
			END CATCH 
END