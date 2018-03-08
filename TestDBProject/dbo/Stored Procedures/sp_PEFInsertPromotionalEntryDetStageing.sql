CREATE PROCEDURE [dbo].[sp_PEFInsertPromotionalEntryDetStageing] 
	 --@AdID AS INT,
	 --@KeyElementID AS INT,
	 @PrmotionDetails dbo.PEFPromotionDetail readonly,
	 @CorpID INT,
	 @CategoryID INT,
	 @TemplateID INT,
	 @UserID INT
AS 
BEGIN 
BEGIN TRY 
BEGIN TRANSACTION

if  EXISTS (SELECT 1 FROM  [Promotion]  WHERE [CropID] = @CorpID )
BEGIN 
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
		SELECT a.[PromotionID],
		b.[CompositeCropStagingID],
			a.[CropID],
			a.[CategoryID],
			a.[AdvertiserID],
			a.[ProductID],
			a.[ProductDescrip],
			0,
			@UserID,
			CURRENT_TIMESTAMP
		FROM [Promotion] a LEFT OUTER JOIN CompositeCropStaging b
		on a.[CropID] = b.[CropID]
		WHERE a.[CropID] = @CorpID
		AND a.[CategoryID]= @CategoryID
		ORDER BY a.[PromotionID]

IF ((SELECT 
	a.[PromotionStagingID]
	FROM [PromotionStaging] a, 
	PromotionDetail b, 
	[RefTemplateElement] c, 
	RefKeyElement d
	WHERE a.[CompositeCropID] = @CorpID
	AND a.[CategoryID] = @CategoryID 	-- EXIST (<CategoryIDParm list>) categories are already validated that they use the same Promotional Template
	AND b.[PromotionID] = a.[PromoID]
	AND c.[KETemplateID] = @TemplateID
	AND a.PromotionStagingID is null
	AND d.[RefKeyElementID] = c.[KeyElementID]) IS NULL)
	BEGIN
		--PRINT 'INSERT INTO PromotionDetail'
		DECLARE @PK_ID INT = 0
		SET @PK_ID = (SELECT TOP 1 [PromoID] FROM [PromotionStaging] ORDER BY [PromoID] DESC)
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
			@PK_ID ,
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
			(
				[PromoStagingID],
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
				ModuleName
			)
			SELECT a.[PromotionStagingID],
				b.[PromotionDetailID],  -- NULL means INSERT in PromotionDetail
				d.[RefKeyElementID],
				d.KeyElementName,
				b.AnsVarchar,
				b.AnsMemo,
				b.AnsNumeric,
				b.AnsTimestamp,
				b.AnsBoolean,
				b.AnsConfigValue,
				d.KElementDataType,
				d.MaskFormat,
				d.[MultiInd],
				c.[ReqdInd],
				c.DefaultValue,
				c.GroupCode,
				c.DisplayOrder,
				d.SystemName,
				d.ComponentName

			FROM [PromotionStaging] a, 
			PromotionDetail b
			RIGHT OUTER JOIN [RefTemplateElement] c ON b.[KeyElementID] = c.[KeyElementID], 
			RefKeyElement d
			WHERE a.[CompositeCropID] = @CorpID
			AND a.[CategoryID] =@CategoryID
			--EXIST (<CategoryIDParm list>)	/// categories are 	already validated that they use the same Promotional Template
			AND b.[PromotionID] = a.[PromoID]
			AND c.[KETemplateID] = @TemplateID
			AND d.[RefKeyElementID] = c.[KeyElementID]
	END
	ELSE
	BEGIN
		--PRINT 'INSERT INTO PromotionalDetailStaging'
		INSERT INTO [PromotionalDetailStaging]
			(
				[PromoStagingID],
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
				ModuleName
			)
			SELECT a.[PromotionStagingID],
				b.[PromotionDetailID],  -- NULL means INSERT in PromotionDetail
				d.[RefKeyElementID],
				d.KeyElementName,
				b.AnsVarchar,
				b.AnsMemo,
				b.AnsNumeric,
				b.AnsTimestamp,
				b.AnsBoolean,
				b.AnsConfigValue,
				d.KElementDataType,
				d.MaskFormat,
				d.[MultiInd],
				c.[ReqdInd],
				c.DefaultValue,
				c.GroupCode,
				c.DisplayOrder,
				d.SystemName,
				d.ComponentName

			FROM [PromotionStaging] a, 
			PromotionDetail b
			RIGHT OUTER JOIN [RefTemplateElement] c ON b.[KeyElementID] = c.[KeyElementID], 
			RefKeyElement d
			WHERE a.[CompositeCropID] = @CorpID
			AND a.[CategoryID] =@CategoryID
			--EXIST (<CategoryIDParm list>)	/// categories are 	already validated that they use the same Promotional Template
			AND b.[PromotionID] = a.[PromoID]
			AND c.[KETemplateID] = @TemplateID
			AND d.[RefKeyElementID] = c.[KeyElementID]

--AND b.FK_KeyElementID =* c.FK_KeyElementID	/// OUTER RIGHT JOIN to give  
	END
end

COMMIT TRANSACTION	
	  END TRY
	  BEGIN CATCH 
		  DECLARE @error   INT,
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('sp_PEFDeletePromotionalEntryStageing: %d: %s',16,1,@error,@message,@lineNo); 
		  
      END catch; 
	    END;