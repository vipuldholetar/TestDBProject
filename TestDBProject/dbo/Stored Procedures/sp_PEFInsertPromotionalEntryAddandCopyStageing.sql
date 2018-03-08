CREATE PROCEDURE [dbo].[sp_PEFInsertPromotionalEntryAddandCopyStageing] 
	 @PrmotionDetails dbo.PEFPromotionDetail readonly,
	 @CorpID INT,
	 @CategoryID INT,
	--@TemplateID INT,
	 @UserID INT,
	 @NoOFRecord INT
AS 
BEGIN 
	BEGIN TRY 
		BEGIN TRAN	
			DECLARE @PromotionMasterStagingID INT = 0
			DECLARE @Count INT = 0
			WHILE (@NoOFRecord>@Count) 
			BEGIN
				--PRINT 'tESET INSIDDFRE'
				DECLARE @PK_ID INT = 0
				SET @PK_ID=(SELECT TOP 1 [PromotionStagingID] FROM [PromotionStaging] WHERE [CompositeCropID]=@CorpID and [CategoryID]=@CategoryID ORDER BY [PromotionStagingID] DESC )
				INSERT INTO [PromotionStaging]
					([PromoID],
					[CompositeCropStagingID],
					[CompositeCropID],
					[CategoryID],
					[AdvertiserID],
					[ProductID],
					[ProductDescrip],
					[DeletedInd],
					[LockedByID],
					[LockedDT])
	
					SELECT [PromoID],
						[CompositeCropStagingID],	
						[CompositeCropID],	--/// same Crop
						[CategoryID],		--/// same Category
						AdvertiserID,
						NULL,
						NULL,
						0,
						@UserID,
						CURRENT_TIMESTAMP
						FROM [PromotionStaging]
					WHERE [PromotionStagingID] = @PK_ID

				SET	@PromotionMasterStagingID = SCOPE_IDENTITY()
	
					--/// Update PromotionDetailStaging with a blank row for each Key Element for capture.
				IF ((SELECT TOP 1 a.[PromotionStagingID]
				FROM [PromotionStaging] a, 
				[PromotionalDetailStaging] b 
				WHERE a.[PromotionStagingID] =@PK_ID
				AND b.[PromoStagingID] = a.[PromotionStagingID]
				) IS NULL)
				BEGIN																																																																										BEGIN
					--PRINT 'INSERT INTO PromotionDetail'
					DECLARE @PK_IDMasterID INT = 0
					SET @PK_IDMasterID = (SELECT TOP 1 [PromoID] FROM [PromotionStaging] ORDER BY [PromoID] DESC)
					INSERT INTO PromotionDetail(
					[PromotionID],
					[KeyElementID],
					AnsVarchar,
					AnsMemo,
					AnsNumeric,
					AnsTimestamp,
					AnsBoolean,
					AnsConfigValue,
					[CreatedDT],
					[CreatedByID]
					)
					--SELECT TOP 1 FK_PromoMasterID FROM PromotionMasterStaging ORDER BY FK_PromoMasterID DESC,
					SELECT 
						@PK_IDMasterID ,
						[FK_KeyElementID],
						[AnsVarchar] ,
						[AnsMemo], 
						[AnsNumeric] ,
						[AnsTimestamp],
						[AnsBoolean],
						[AnsConfigValue] ,
						[CreateDate],
						[CreateBy] 
	
						FROM @PrmotionDetails

						INSERT INTO [PromotionalDetailStaging]																																											
							([PromoStagingID],
							[PromoDetailID],
							[KeyElementID],
							KeyElementName,
							AnsVarchar,
							AnsMemo,
							AnsNumeric,
							AnsTimestamp,
							AnsBoolean,
							AnsConfigValue,
							KElementDataType,
							MaskFormat,
							[MultiInd],
							[ReqdInd],
							DefaultValue,
							[GroupCODE],
							DisplayOrder,
							SystemName,
							ModuleName)
							SELECT DISTINCT @PromotionMasterStagingID,	
							--/// DISTINCT to eliminate multiple values where MultiIndicator = True NULL,  /// NULL means INSERT in PromotionDetail
							b.[PromoDetailID],
							b.[KeyElementID],
							b.KeyElementName,
							b.AnsVarchar,		
							b.AnsMemo,		
							b.AnsNumeric,		
							b.AnsTimestamp,	
							b.AnsBoolean,		
							b.AnsConfigValue,	
							b.KElementDataType,
							b.MaskFormat,
							b.[MultiInd],
							b.[ReqdInd],
							b.DefaultValue,
							b.[GroupCODE],
							b.DisplayOrder,
							b.SystemName,
							b.ModuleName
						FROM [PromotionStaging] a, 
						[PromotionalDetailStaging] b 
						--@PrmotionDetails b
						WHERE a.[PromotionStagingID] = @PK_IDMasterID
						AND b.[PromoStagingID] = a.[PromotionStagingID]
					END
					END
				ELSE
				BEGIN																																																				BEGIN
				--PRINT 'INSERT INTO PromotionalDetailStaging'
				INSERT INTO [PromotionalDetailStaging]																																											
							([PromoStagingID],
							[PromoDetailID],
							[KeyElementID],
							KeyElementName,
							AnsVarchar,
							AnsMemo,
							AnsNumeric,
							AnsTimestamp,
							AnsBoolean,
							AnsConfigValue,
							KElementDataType,
							MaskFormat,
							[MultiInd],
							[ReqdInd],
							DefaultValue,
							[GroupCODE],
							DisplayOrder,
							SystemName,
							ModuleName)
							SELECT DISTINCT @PromotionMasterStagingID,	
							--/// DISTINCT to eliminate multiple values where MultiIndicator = True NULL,  /// NULL means INSERT in PromotionDetail
							b.[PromoDetailID],
							b.[KeyElementID],
							b.KeyElementName,
							b.AnsVarchar,		
							b.AnsMemo,		
							b.AnsNumeric,		
							b.AnsTimestamp,	
							b.AnsBoolean,		
							b.AnsConfigValue,
							--c.AnsVarchar,		
							--c.AnsMemo,		
							--c.AnsNumeric,		
							--c.AnsTimestamp,	
							--c.AnsBoolean,		
							--c.AnsConfigValue,	
							b.KElementDataType,
							b.MaskFormat,
							b.[MultiInd],
							b.[ReqdInd],
							b.DefaultValue,
							b.[GroupCODE],
							b.DisplayOrder,
							b.SystemName,
							b.ModuleName
						FROM [PromotionStaging] a, 
						[PromotionalDetailStaging] b ,
						@PrmotionDetails c
						WHERE a.[PromotionStagingID] = @PK_ID
						AND b.[PromoStagingID] = a.[PromotionStagingID]
						AND c.FK_KeyElementID=b.[KeyElementID]
				END
				--AND b.FK_KeyElementID =* c.FK_KeyElementID	/// OUTER RIGHT JOIN to give  

				END
				SET @Count=@Count +1
			END

		COMMIT TRAN
		
	END TRY
	BEGIN CATCH 
		DECLARE @error   INT,
				@message VARCHAR(4000), 
				@lineNo  INT 

		SELECT @error = Error_number(), 
				@message = Error_message(), 
				@lineNo = Error_line() 

		RAISERROR ('sp_PEFInsertPromotionalEntryAddandCopyStageing: %d: %s',16,1,@error,@message,@lineNo); 
		  
	END catch 
END