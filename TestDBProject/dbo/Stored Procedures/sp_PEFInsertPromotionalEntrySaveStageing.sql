CREATE PROCEDURE [dbo].[sp_PEFInsertPromotionalEntrySaveStageing] 
@UserID INT,
@AdID INT 
AS 
BEGIN 
	BEGIN TRY 
		BEGIN TRAN	
		-- This  table variable will hold Element  conditions during condition  check
		 DECLARE @PromotionMaster TABLE
		(
			[RowId] [INT] IDENTITY(1,1) NOT NULL,		
			[PK_ID] int ,
			[FK_CompositeCropStagingID] int ,
			[FK_PromoMasterID] int,
			[FK_CompositeCropID] int,
			[FK_CategoryID] int ,
			[FK_AdvertiserID] int ,
			[FK_ProductID] int ,
			[ProductDescription] nvarchar(max) ,
			[DeletedIndicator] bit ,
			[PromoDetailIndicator] bit ,
			[LockedBy] int  ,
			[LockedOn] datetime  
			);
		 DECLARE @PromotionDetails TABLE
			(
			[RowId] [INT] IDENTITY(1,1) NOT NULL,	
			[FK_PromoMasterStagingID] [int] NOT NULL,
			[FK_PromoDetailID] [int] NOT NULL,
			[FK_KeyElementID] [int] NOT NULL,
			[KeyElementName] [nvarchar](max) NULL,
			[AnsVarchar] [nvarchar](max) NULL,
			[AnsMemo] [nvarchar](max) NULL,
			[AnsNumeric] [decimal](18, 0) NULL,
			[AnsTimestamp] [datetime] NULL,
			[AnsBoolean] [bit] NULL,
			[AnsConfigValue] [nvarchar](max) NULL,
			[KElementDataType] [nvarchar](max) NULL,
			[MaskFormat] [nvarchar](max) NULL,
			[MultiIndicator] [char](2) NULL,
			[ReqdIndicator] [char](2) NULL,
			[DefaultValue] [nvarchar](max) NULL,
			[GroupCode] [nvarchar](max) NULL,
			[DisplayOrder] [int] NULL,
			[SystemName] [nvarchar](max) NULL,
			[ModuleName] [nvarchar](max) NULL
			)
		 INSERT INTO @PromotionDetails
			(
			[FK_PromoMasterStagingID] ,
			[FK_PromoDetailID] ,
			[FK_KeyElementID] ,
			[KeyElementName] ,
			[AnsVarchar] ,
			[AnsMemo] ,
			[AnsNumeric] ,
			[AnsTimestamp],
			[AnsBoolean] ,
			[AnsConfigValue] ,
			[KElementDataType] ,
			[MaskFormat] ,
			[MultiIndicator] ,
			[ReqdIndicator] ,
			[DefaultValue] ,
			[GroupCode] ,
			[DisplayOrder],
			[SystemName] ,
			[ModuleName] 
			)
			SELECT[PromoStagingID] ,
			[PromoDetailID] ,
			[KeyElementID] ,
			[KeyElementName] ,
			[AnsVarchar] ,
			[AnsMemo] ,
			[AnsNumeric] ,
			[AnsTimestamp] ,
			[AnsBoolean] ,
			[AnsConfigValue] ,
			[KElementDataType] ,
			[MaskFormat] ,
			[MultiInd] ,
			[ReqdInd] ,
			[DefaultValue] ,
			[GroupCODE] ,
			[DisplayOrder] ,
			[SystemName] ,
			[ModuleName]   FROM [PromotionalDetailStaging] 

		 INSERT INTO @PromotionMaster
		(
		[PK_ID],
			[FK_CompositeCropStagingID],
			[FK_PromoMasterID] ,
			[FK_CompositeCropID] ,
			[FK_CategoryID],
			[FK_AdvertiserID] ,
			[FK_ProductID] ,
			[ProductDescription] ,
			[DeletedIndicator] ,
			[PromoDetailIndicator] ,
			[LockedBy] ,
			[LockedOn]
		)
		SELECT  
		[PromotionStagingID],
		[CompositeCropStagingID],
			[PromoID] ,
			[CompositeCropID] ,
			[CategoryID],
			[AdvertiserID] ,
			[ProductID] ,
			[ProductDescrip] ,
			[DeletedInd] ,
			[PromoDetailInd] ,
			[LockedByID] ,
			[LockedDT]
		FROM PromotionStaging WHERE [LockedByID]= @UserID


		DECLARE @PromotionMasterStagingID INT = 0
		DECLARE @PromoMasterID INT = 0
		DECLARE @DeleteIndicator INT = 0
		DECLARE @PrmoMasterStaID int=0
		DECLARE @AdvertiserID int

		select @AdvertiserID=[AdvertiserID] from Ad where [AdID]=@AdID
		
		DECLARE @MaxRowID int;
		SELECT @MaxRowID = MAX(RowId) From @PromotionMaster

		DECLARE @RowId int;
		Set @RowId = 1
		
		SELECT @DeleteIndicator = DeletedIndicator FROM @PromotionMaster WHERE RowId=@RowId
		 print  @DeleteIndicator
		WHILE @RowId <= @MaxRowID
		BEGIN
		
			SELECT @PromotionMasterStagingID = PK_ID FROM @PromotionMaster WHERE RowId=@RowId
			SELECT @PromoMasterID = FK_PromoMasterID FROM @PromotionMaster  WHERE RowId=@RowId
			SELECT @DeleteIndicator = DeletedIndicator FROM @PromotionMaster WHERE RowId=@RowId
		  
			IF (@PromoMasterID IS NULL AND  (@DeleteIndicator= 0 or @DeleteIndicator is null))
			BEGIN
				--Print('Inside is null')
				INSERT INTO [Promotion]
				([CropID],
				[CategoryID],
				[AdvertiserID] ,
				[ProductID] ,
				[ProductDescrip],
				[CreatedByID],
				[CreatedDT])
				SELECT [FK_CompositeCropID],
				[FK_CategoryID],
				@AdvertiserID,
				1,
				[ProductDescription], 
				@UserID,
				CURRENT_TIMESTAMP FROM @PromotionMaster  WHERE RowId=@RowId
	
				SET @PromoMasterID = SCOPE_IDENTITY()
	
				INSERT INTO PromotionDetail
				([PromotionID],
				[KeyElementID],
				[AnsVarchar],
				[AnsMemo],
				[AnsNumeric],
				[AnsTimestamp],
				[AnsBoolean],
				[AnsConfigValue],
				[CreatedByID],
				[CreatedDT])
				
				SELECT @PromoMasterID,
				[KeyElementID],
				[AnsVarchar],
				[AnsMemo],
				[AnsNumeric],
				[AnsTimestamp],
				[AnsBoolean],
				[AnsConfigValue],
				@UserID,
				CURRENT_TIMESTAMP
				FROM [PromotionalDetailStaging]
				WHERE [PromoStagingID] = @PromotionMasterStagingID

				--/// Reflect the generated PromoMasterID back in the Staging table
				UPDATE [PromotionStaging]
				SET [PromoID] = @PromoMasterID
				WHERE [PromotionStagingID] = @PromotionMasterStagingID
	
				--	/// Reflect the generated PromoDetailIDs back in the Staging table
				--	/// Note, FK_PromoMasterID + FK_KeyElementID + AnsConfigValue is 
				--considered as PromotionDetail candidate key.

				UPDATE [PromotionalDetailStaging]
				SET [PromoDetailID] = b.[PromotionDetailID]
				FROM [PromotionalDetailStaging] a, PromotionDetail b
				WHERE b.[PromotionID] = @PromoMasterID
				AND a.[PromoStagingID] = @PromotionMasterStagingID
				AND a.[KeyElementID] = b.[KeyElementID]
				AND a.AnsConfigValue = b.AnsConfigValue
		
			END
			ELSE IF @PromoMasterID IS NOT NULL
			BEGIN
				IF (@DeleteIndicator= 1)
				BEGIN
					DELETE PromotionDetail
					WHERE [PromotionID] = @PromoMasterID

					DELETE [Promotion]
					WHERE [PromotionID] = @PromoMasterID

					--<Next loop – to not continue the rest of this ELSE IF>
					--select * from Ad
					-- Print('Inside is  not null if condition')
				END
				ELSE
				BEGIN
					Print('Inside is  not null else condition')
					-- For Updating Promotion master table 
					UPDATE [Promotion]
					SET 
					[AdvertiserID] =A.[FK_AdvertiserID],
					[ProductID] =A. [FK_ProductID],
					[ProductDescrip] =A.[ProductDescription],
					[ModifiedByID] = @UserID,
					[ModifiedDT] = CURRENT_TIMESTAMP
					FROM @PromotionMaster A
					WHERE A.PK_ID = @PromoMasterID AND RowId=@RowId
	
					DECLARE @MaxStgRowID int;
					SELECT @MaxStgRowID = MAX(RowId) From @PromotionDetails 
	
					DECLARE @RowStgId int;
					Set @RowStgId = 1

					DECLARE  @PromoDetailStaID INT

					WHILE @RowStgId <= @MaxStgRowID
					BEGIN
						SELECT @PromoDetailStaID = [FK_PromoDetailID]  FROM @PromotionDetails WHERE RowId=@RowStgId AND [FK_PromoMasterStagingID]=@PromotionMasterStagingID
						IF @PromoDetailStaID IS NULL		-- newly added detail; valid scenario since key elements for a template can change overtime.
						BEGIN
				
							INSERT INTO PromotionDetail
							(PromotionID,
							KeyElementID,
							AnsVarchar,
							AnsMemo,
							AnsNumeric,
							AnsTimestamp,
							AnsBoolean,
							AnsConfigValue,
							CreatedByID,
							CreatedDT)
							SELECT  @PromoMasterID,
							[FK_KeyElementID],
							[AnsVarchar],
							[AnsMemo] ,
							[AnsNumeric] ,
							[AnsTimestamp] ,
							[AnsBoolean] ,
							[AnsConfigValue] ,
							@UserID,
							CURRENT_TIMESTAMP FROM @PromotionDetails WHERE FK_PromoMasterStagingID =@PromotionMasterStagingID
							SET	@PromoDetailStaID = SCOPE_IDENTITY()
	
							--/// Reflect the generated PromoDetailID back in the Staging table
							--/// Note, FK_PromoMasterID + FK_KeyElementID + 
							--AnsConfigValue is considered as PromotionDetail candidate key.
	
							UPDATE PromotionalDetailStaging
							SET PromoDetailID = b.PromotionDetailID
							FROM PromotionalDetailStaging a, PromotionDetail b
							WHERE b.PromotionDetailID = @PromoDetailStaID
							AND a.PromoDetailID = @PromotionMasterStagingID
							AND a.KeyElementID = b.KeyElementID
							AND a.AnsConfigValue = b.AnsConfigValue
						END
						ELSE
						BEGIN
				
							UPDATE PromotionDetail
							SET [AnsVarchar] = B.AnsVarchar,
							[AnsMemo] = B.AnsMemo,
							[AnsNumeric] =B.AnsNumeric,
							[AnsTimestamp] = B.AnsTimestamp,
							[AnsBoolean] = B.AnsBoolean,
							[AnsConfigValue] =B.AnsConfigValue,
							[ModifiedByID] = @UserID,
							[ModifiedDT] = CURRENT_TIMESTAMP
							FROM @PromotionDetails B
							WHERE PromotionDetailID = @PromoDetailStaID
						END

							SELECT @RowStgId = @RowStgId +1
					END
		
				END
			END
		
			SELECT  @RowId = @RowId + 1
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

		RAISERROR ('sp_PEFInsertPromotionalEntrySaveStageing: %d: %s',16,1,@error,@message,@lineNo); 
		  
	END catch 
END