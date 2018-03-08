CREATE PROCEDURE [dbo].[sp_PEFInsertPromotionalEntryAddStageing] 
	 --@PrmotionDetails dbo.PEFPromotionDetail readonly,
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
	
					SELECT NULL,
						[CompositeCropStagingID],	
						[CompositeCropID],	--/// same Crop
						[CategoryID],		--/// same Category
						NULL,
						NULL,
						NULL,
						0,
						@UserID,
						CURRENT_TIMESTAMP
						FROM [PromotionStaging]
					WHERE [PromotionStagingID] = @PK_ID

				SET	@PromotionMasterStagingID = SCOPE_IDENTITY()
	
					--/// Update PromotionDetailStaging with a blank row for each Key Element for capture.
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
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
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
			WHERE a.[PromotionStagingID] = @PK_ID
			AND b.[PromoStagingID] = a.[PromotionStagingID]
				--ORDER BY a.PK_ID, 
				--c.GroupCode, c.DisplayOrder, 
				--d.KeyElementName, 
				--b.AnsConfigValue

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

		RAISERROR ('sp_PEFInsertPromotionalEntryAddStageing: %d: %s',16,1,@error,@message,@lineNo); 
		  
	END catch 
END