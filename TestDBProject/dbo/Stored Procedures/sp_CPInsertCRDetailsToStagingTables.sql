-- =============================================
-- Author:		Monika. J
-- Create date: 11-12-2015
-- Description:	To Insert All CR Details to Staging Tables
-- Execution:   sp_CPInsertCRDetailsToStagingTables 23645,530038,29712222,'CIRCULAR' 
-- =============================================
CREATE PROCEDURE [dbo].[sp_CPInsertCRDetailsToStagingTables] 
	-- Add the parameters for the stored procedure here
	@AdID INT,
	@Occurrence_ID INT,
	@UserID INT,
	@MediaStream VARCHAR(50)
AS
		BEGIN
			-- SET NOCOUNT ON added to prevent extra result sets from
			-- interfering with SELECT statements.
			SET NOCOUNT ON;
		BEGIN TRY
			-- Insert statements for procedure here
			DECLARE @OccurrenceID INT
			DECLARE @CreativeCropID INT
			DECLARE @CreativeCropStagingID INT
			DECLARE @CompositeCropStagingID INT
			DECLARE @CreativeDetailStagingID INT
			SET @OccurrenceID = CASE WHEN @Occurrence_ID != NULL THEN @Occurrence_ID
				ELSE (SELECT [PrimaryOccurrenceID] FROM Ad WHERE [AdID] = @AdID) END
			--select 	@OccurrenceID 
			SELECT @CreativeCropID = [CreativeForCropID] FROM [CreativeForCrop]
				WHERE [CreativeID] = @AdID	AND [OccurrenceID] = @OccurrenceID
			--select 	@CreativeCropID 
			--select * from Ad where PK_ID=7346
			--select * from CreativeforCrop WHERE FK_ID = 7346	AND FK_OccurrenceID = 2038
		BEGIN TRANSACTION

		IF @CreativeCropID IS NULL	--/// meaning the Ad/Occurrence has not been cropped yet
		BEGIN
			 INSERT INTO CreativeForCrop(CreativeID,OccurrenceID,CreativeMasterID,MediaStream,AdDate)
			 SELECT A.AdID,@OccurrenceID,A.CreativeID,A.MediaStream,AdDate
				FROM ufn_OccurrenceDetails (@OccurrenceID) a, [Pattern] b
				WHERE b.[PatternID] = a.FK_PatternMasterID
				AND a.ADID IS NOT NULL
			 
			 SET @CreativeCropID = SCOPE_IDENTITY()

			 IF NOT EXISTS(SELECT CreativeForCropStagingID FROM [CreativeForCropStaging] WHERE AdID=@AdID and OccurrenceID = @OccurrenceID)
			 BEGIN
			    INSERT INTO [CreativeForCropStaging]
				    ([CreativeCropID],
				    [AdID],
				    [OccurrenceID],
				    [AdDT],
				    [CreativeMasterStagingID],
				    MediaStream,
				    [LockedByID],
				    [LockedDT])

			    SELECT @CreativeCropID, 
				    @AdID, 
				    @OccurrenceID, 
				    a.AdDate,
				    b.[CreativeID], 
				    b.MediaStream,
				    @UserID,
				    CURRENT_TIMESTAMP
				    FROM ufn_OccurrenceDetails (@OccurrenceID) a, [Pattern] b
				    WHERE b.[PatternID] = a.FK_PatternMasterID
		
			    SET @CreativeCropStagingID = SCOPE_IDENTITY()
			 END
			 ELSE
			 BEGIN
				SELECT @CreativeCropStagingID=CreativeForCropStagingID FROM [CreativeForCropStaging] WHERE AdID=@AdID and OccurrenceID = @OccurrenceID
			 END
			--/// Make all Creatives/Pages already available at the start for Crop

			IF (@MediaStream ='CIRCULAR')
			 BEGIN
				INSERT INTO CreativeContentDetailStaging
						([CreativeCropStagingID],[ContentDetailID],[CreativeDetailID],
						SellableSpaceCoordX1,SellableSpaceCoordY1,SellableSpaceCoordX2,
						SellableSpaceCoordY2,LockedByID,LockedDT)
				SELECT a.[CreativeForCropStagingID],NULL,b.CreativeDetailID,0, 0, 0, 0,@UserID,CURRENT_TIMESTAMP		
					FROM [CreativeForCropStaging] a inner join CreativeDetailCIR b on b.CreativeMasterID = a.[CreativeMasterStagingID]
					LEFT JOIN CreativeContentDetailStaging c on c.CreativeCropStagingID = a.[CreativeForCropStagingID]
					AND c.[CreativeDetailID] = b.CreativeDetailID
					WHERE  c.ContentDetailID is null and a.[CreativeForCropStagingID] = @CreativeCropStagingID
					AND b.Deleted = 0
					
				SET @CreativeDetailStagingID = SCOPE_IDENTITY()
			 END					
			ELSE IF (@MediaStream ='Publication')
			BEGIN
				INSERT INTO CreativeContentDetailStaging
						([CreativeCropStagingID],[ContentDetailID],[CreativeDetailID],
						SellableSpaceCoordX1,SellableSpaceCoordY1,SellableSpaceCoordX2,
						SellableSpaceCoordY2,LockedByID,LockedDT)
				SELECT a.[CreativeForCropStagingID],NULL,b.CreativeDetailID,0, 0, 0, 0,@UserID,CURRENT_TIMESTAMP	
					FROM [CreativeForCropStaging] a inner join  CreativeDetailPUB b on b.CreativeMasterID = a.[CreativeMasterStagingID]
					LEFT JOIN CreativeContentDetailStaging c on c.CreativeCropStagingID = a.[CreativeForCropStagingID]
					AND c.[CreativeDetailID] = b.CreativeDetailID
					WHERE  c.ContentDetailID is null and  a.[CreativeForCropStagingID] = @CreativeCropStagingID 
					AND b.Deleted = 0

				SET @CreativeDetailStagingID = SCOPE_IDENTITY()
			END
			ELSE IF(@MediaStream ='Email')
			BEGIN
					INSERT INTO CreativeContentDetailStaging
						([CreativeCropStagingID],[ContentDetailID],[CreativeDetailID],
						SellableSpaceCoordX1,SellableSpaceCoordY1,SellableSpaceCoordX2,
						SellableSpaceCoordY2,LockedByID,LockedDT)
					SELECT a.[CreativeForCropStagingID],NULL,b.[CreativeDetailsEMID],0, 0, 0, 0,@UserID,CURRENT_TIMESTAMP		
						FROM [CreativeForCropStaging] a inner join CreativeDetailEM b on b.CreativeMasterID = a.[CreativeMasterStagingID]
						LEFT JOIN CreativeContentDetailStaging c on c.CreativeCropStagingID = a.[CreativeForCropStagingID]
					AND c.[CreativeDetailID] = b.[CreativeDetailsEMID]
					WHERE  c.ContentDetailID is null and  a.[CreativeForCropStagingID] = @CreativeCropStagingID 
					AND b.Deleted = 0

					SET @CreativeDetailStagingID = SCOPE_IDENTITY()
			END
			ELSE IF(@MediaStream ='Website')
			BEGIN
					INSERT INTO CreativeContentDetailStaging
						([CreativeCropStagingID],[ContentDetailID],[CreativeDetailID],
						SellableSpaceCoordX1,SellableSpaceCoordY1,SellableSpaceCoordX2,SellableSpaceCoordY2)
					SELECT a.[CreativeForCropStagingID],NULL,b.[CreativeDetailWebID],0, 0, 0, 0	
						FROM [CreativeForCropStaging] a inner join CreativeDetailWeb b on b.CreativeMasterID = a.[CreativeMasterStagingID]
						LEFT JOIN CreativeContentDetailStaging c on c.CreativeCropStagingID = a.[CreativeForCropStagingID]
					AND c.[CreativeDetailID] = b.[CreativeDetailWebID]
					WHERE  c.ContentDetailID is null and  a.[CreativeForCropStagingID] = @CreativeCropStagingID 
					AND b.Deleted = 0				

					SET @CreativeDetailStagingID = SCOPE_IDENTITY()
			END

			SELECT Top 1 @CompositeCropStagingID = [CompositeCropStagingID] FROM CompositeCropStaging where [CreativeCropStagingID]=@CreativeCropStagingID order by [CompositeCropStagingID] desc
				
		END
		ELSE
		BEGIN
		-- For CreativeforCrop Data
		IF(NOT EXISTS(SELECT [CreativeCropID] FROM [CreativeForCropStaging] WHERE [CreativeCropID] = @CreativeCropID))
		  BEGIN
			INSERT INTO [CreativeForCropStaging]
				([CreativeCropID],
				[AdID],
				[OccurrenceID],
				[AdDT],
				[CreativeMasterStagingID],
				MediaStream,
				[LockedByID],
				[LockedDT])

			SELECT [CreativeForCropID], 
				[CreativeID], 
				[OccurrenceID], 
				AdDate,
				[CreativeMasterID], 
				MediaStream,
				@UserID,
				CURRENT_TIMESTAMP
				FROM [CreativeForCrop]
				WHERE [CreativeForCropID] = @CreativeCropID

				SET @CreativeCropStagingID = SCOPE_IDENTITY()
		  END
		  ELSE
		  BEGIN
			 SELECT @CreativeCropStagingID = CreativeForCropStagingID FROM [CreativeForCropStaging] WHERE [CreativeCropID] = @CreativeCropID
		  END
		-- For CompositeCrop Data

		IF(NOT EXISTS(SELECT [CreativeCropStagingID] FROM CompositeCropStaging WHERE [CreativeCropStagingID] = @CreativeCropStagingID))
	     BEGIN
		    INSERT INTO CompositeCropStaging
			    ([CreativeCropStagingID],
			    [CropID],
			    [Deleted])
		    SELECT b.[CreativeForCropStagingID],
			    a.[CompositeCropID],
			    0
			    FROM CompositeCrop a, [CreativeForCropStaging] b
			    WHERE b.[CreativeCropID] = @CreativeCropID
			    AND a.[CreativeCropID] = b.[CreativeCropID]

			    SET @CompositeCropStagingID = SCOPE_IDENTITY()
		  END
		  ELSE
		  BEGIN
			 SELECT @CompositeCropStagingID = CompositeCropStagingID FROM CompositeCropStaging WHERE [CreativeCropStagingID] = @CreativeCropStagingID
		  END

	   IF(NOT EXISTS(SELECT [CompositeCropStagingID] FROM CropCategoryGroupStaging WHERE [CompositeCropStagingID] = @CompositeCropStagingID))
	     BEGIN
		    -- For CropCategoryGroup Data
		    INSERT INTO CropCategoryGroupStaging
			    ([CompositeCropStagingID],
			    [CategoryGroupID])
		    SELECT b.[CompositeCropStagingID],
			    a.[CategoryGroupID]
			    FROM CropCategoryGroup a, CompositeCropStaging b, [CreativeForCropStaging] c
			    WHERE c.[CreativeCropID] = @CreativeCropID
			    AND b.[CreativeCropStagingID] = c.[CreativeForCropStagingID]
			    AND a.[CropCategoryGroupID] = b.[CropID]
		END

		IF(NOT EXISTS(SELECT [CreativeCropStagingID] FROM CreativeContentDetailStaging WHERE [CreativeCropStagingID] = @CreativeCropStagingID))
	     BEGIN
		-- For CreativeContentDetail Data
		INSERT INTO CreativeContentDetailStaging
			([ContentDetailID],
			[CreativeCropStagingID],
			[CreativeDetailID],
			SellableSpaceCoordX1,
			SellableSpaceCoordY1,
			SellableSpaceCoordX2,
			SellableSpaceCoordY2,
			[LockedByID],
			[LockedDT])
		SELECT a.[CreativeContentDetailID],
			b.[CreativeForCropStagingID],
			a.[CreativeDetailID],
			a.SellableSpaceCoordX1,
			a.SellableSpaceCoordY1,
			a.SellableSpaceCoordX2,
			a.SellableSpaceCoordY2,
			@UserID,
			CURRENT_TIMESTAMP
		FROM CreativeContentDetail a, [CreativeForCropStaging] b
		WHERE a.[CreativeCropID] = @CreativeCropID
		AND b.[CreativeCropID] = a.[CreativeCropID]				
		
			SET @CreativeDetailStagingID = SCOPE_IDENTITY()
	   END
	   ELSE
	   BEGIN
		  SELECT @CreativeDetailStagingID=CreativeContentDetailStagingID FROM CreativeContentDetailStaging 
		  WHERE [CreativeCropStagingID] = @CreativeCropStagingID
	   END

	   IF(NOT EXISTS(SELECT [ContentDetailStagingID] FROM CropDetailIncludeStaging WHERE [ContentDetailStagingID] = @CreativeDetailStagingID))
	     BEGIN
		-- For CropDetailInclude Data
		INSERT INTO CropDetailIncludeStaging
			([CompositeCropStagingID],
			[ContentDetailStagingID],
			CropRectCoordX1,
			CropRectCoordY1,
			CropRectCoordX2,
			CropRectCoordY2)
		  select b.[CompositeCropStagingID],c.[CreativeContentDetailStagingID],a.CropRectCoordX1,a.CropRectCoordY1,CropRectCoordX2,CropRectCoordY2 from CreativeDetailInclude a INNER JOIN 
		  CompositeCropStaging b ON b.[CropID]=a.FK_CropID INNER JOIN [CreativeForCropStaging] d ON d.[CreativeForCropStagingID]=b.[CreativeCropStagingID] 
		  JOIN CreativeContentDetailStaging c ON c.[ContentDetailID]=a.FK_ContentDetailID where d.[CreativeCropID]=@CreativeCropID
	   END
			----	SELECT c.PK_ID,
			----b.PK_ID,
			----a.CropRectCoordX1,
			----a.CropRectCoordY1,
			----a.CropRectCoordX2,
			----a.CropRectCoordY2
			----FROM CreativeDetailInclude a, CreativeContentDetailStaging b, CreativeforCropStaging c
			----WHERE c.FK_CreativeCropID = @CreativeCropID
			----AND b.FK_CreativeCropStagingID = c.PK_ID
			----AND a.FK_ContentDetailID = b.FK_ContentDetailID

		--SELECT c.PK_ID,
		--	b.PK_ID,
		--	a.CropRectCoordX1,
		--	a.CropRectCoordY1,
		--	a.CropRectCoordX2,
		--	a.CropRectCoordY2
		--FROM CreativeDetailInclude a, CreativeContentDetailStaging b, CompositeCropStaging c
		--WHERE c.FK_CreativeCropStagingID = @CreativeCropStagingID
		--AND b.FK_CreativeCropStagingID = c.PK_ID
		--AND a.FK_ContentDetailID = b.FK_ContentDetailID

		IF(NOT EXISTS(SELECT [ContentDetailStagingID] FROM CropDetailExcludeStaging WHERE [ContentDetailStagingID] = @CreativeDetailStagingID))
	     BEGIN
		    -- For CropDetailExclude Data
		    INSERT INTO CropDetailExcludeStaging
			    ([ContentDetailStagingID],
			    CropRectCoordX1,
			    CropRectCoordY1,
			    CropRectCoordX2,
			    CropRectCoordY2)			
		    SELECT b.[CreativeContentDetailStagingID],
			    a.CropRectCoordX1,
			    a.CropRectCoordY1,
			    a.CropRectCoordX2,
			    a.CropRectCoordY2
		    FROM CreativeDetailExclude a, CreativeContentDetailStaging b, [CreativeForCropStaging] c
		    WHERE c.[CreativeCropID] = @CreativeCropID
		    AND b.[CreativeCropStagingID] = c.[CreativeForCropStagingID]
		    AND a.FK_ContentDetailID = b.[ContentDetailID]
		END

		IF(NOT EXISTS(SELECT [CreativeCropStagingID] FROM AdPromotionStaging WHERE [CreativeCropStagingID] = @CreativeCropStagingID))
	     BEGIN
		    -- For AdPromotion Data
		    INSERT INTO AdPromotionStaging
			    ([CreativeCropStagingID],
			    [RecordStagingID],
			    RecordType,
			    [PromotionID])
			
		    SELECT b.[CreativeForCropStagingID],
			    b.[CreativeForCropStagingID],
			    a.RecordType,
			    a.[AdPromotionID]
		    FROM AdPromotion a, [CreativeForCropStaging] b
		    WHERE b.[CreativeCropID] = @CreativeCropID
		    AND a.RecordType = 'A'	--/// for whole Ad
		    AND a.RecordID = b.[CreativeCropID]
		
		    UNION ALL

		    SELECT b.[CreativeForCropStagingID], 
			    c.[CompositeCropStagingID],
			    a.RecordType,
			    a.[AdPromotionID]
		    FROM AdPromotion a, [CreativeForCropStaging] b, CompositeCropStaging c
		    WHERE b.[CreativeCropID] = @CreativeCropID
		    AND a.RecordType = 'C'		--/// for the Composite Image only
		    AND c.[CreativeCropStagingID] = b.[CreativeForCropStagingID]
		    AND a.RecordID = c.[CropID]
		
		    UNION ALL

		    SELECT b.[CreativeForCropStagingID],
		    c.[CreativeContentDetailStagingID],
			    a.RecordType,
			    a.[AdPromotionID]
		    FROM AdPromotion a, [CreativeForCropStaging] b, CreativeContentDetailStaging c
		    WHERE b.[CreativeCropID] = @CreativeCropID
		    AND a.RecordType = 'P'		--/// for the whole Page
		    AND c.[CreativeCropStagingID] = b.[CreativeForCropStagingID]
		    AND a.RecordID = c.[ContentDetailID]
		END	
	   END
		--ELSE
		--	BEGIN
		--		SELECT @CreativeCropStagingID= [CreativeForCropStagingID] FROM [CreativeForCropStaging] where [CreativeCropID]=@CreativeCropID
		--		SELECT Top 1 @CompositeCropStagingID = [CompositeCropStagingID] FROM CompositeCropStaging where [CreativeCropStagingID]=@CreativeCropStagingID order by [CompositeCropStagingID] desc
		--		SELECT @CreativeDetailStagingID= [CreativeContentDetailStagingID] FROM CreativeContentDetailStaging where [CreativeCropStagingID]=@CreativeCropStagingID
		--	END
		--END
		SELECT @CreativeCropID as CreativeCropID, @CreativeCropStagingID as CreativeCropStg, @CompositeCropStagingID as CompositeStg, @CreativeDetailStagingID as ContentStg
		COMMIT TRANSACTION
		END TRY

	BEGIN CATCH 
				  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
				  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				  RAISERROR ('sp_CPInsertQueryDetailsInAdClassWorkQueue: %d: %s',16,1,@error,@message,@lineNo); 
				  ROLLBACK TRANSACTION
	END CATCH 
		END