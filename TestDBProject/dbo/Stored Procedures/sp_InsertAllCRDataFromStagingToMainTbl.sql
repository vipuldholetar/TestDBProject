-- =============================================
-- Author:		Monika. J
-- Create date: 11/13/15
-- Description:	To Insert crop data to main tables
-- Execution: [sp_InsertAllCRDataFromStagingToMainTbl] 29712222 , 7055
-- =============================================
CREATE PROCEDURE [dbo].[sp_InsertAllCRDataFromStagingToMainTbl] 
	-- Add the parameters for the stored procedure here
	@UserID int,
	@CreativeforCropStg int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from select * from CreativeforCropStaging
	-- interfering with SELECT statements.  
	SET NOCOUNT ON;
	BEGIN TRY
		-- Insert statements for procedure here
		BEGIN TRANSACTION
		DECLARE @CreativeCropID INT
		--CreativeforCrop & CreativeContentDetail
		SET @CreativeCropID = (SELECT [CreativeCropID] FROM [CreativeForCropStaging] WHERE [LockedByID] = @UserID AND [CreativeForCropStagingID]=@CreativeforCropStg)
		IF (SELECT [CreativeCropID] FROM [CreativeForCropStaging] WHERE [LockedByID] = @UserID AND [CreativeForCropStagingID]=@CreativeforCropStg) = NULL	--/// Newly Cropped Ad
			BEGIN
				INSERT INTO [CreativeForCrop]
					([CreativeID],[OccurrenceID],AdDate,[CreativeMasterID],MediaStream,[CompletedByID],[CompletedDT])
				SELECT [AdID],[OccurrenceID],[AdDT],[CreativeMasterStagingID],MediaStream,@UserID,CURRENT_TIMESTAMP
					FROM [CreativeForCropStaging]	WHERE [LockedByID] = @UserID
		
					SELECT @CreativeCropID = SCOPE_IDENTITY()

					--/// Reflect new key back in their corresponding work table for reference later
					UPDATE [CreativeForCropStaging] SET [CreativeCropID] = @CreativeCropID	WHERE [LockedByID] = @UserID
				
					INSERT INTO CreativeContentDetail
						([CreativeCropID],[CreativeDetailID],SellableSpaceCoordX1,SellableSpaceCoordY1,SellableSpaceCoordX2,SellableSpaceCoordY2,SellableSpaceArea)
	
					SELECT @CreativeCropID,a.[CreativeDetailID],a.SellableSpaceCoordX1,a.SellableSpaceCoordY1,a.SellableSpaceCoordX2,a.SellableSpaceCoordY2,
						ABS(a.SellableSpaceCoordX2-a.SellableSpaceCoordX1)*ABS(a.SellableSpaceCoordY2-a.SellableSpaceCoordY1)
					FROM CreativeContentDetailStaging a, [CreativeForCropStaging] b
					WHERE b.[LockedByID] = @UserID AND a.[CreativeCropStagingID] = b.[CreativeForCropStagingID] AND b.[CreativeCropID]=@CreativeCropID
					
					-- Update corresponding CreativeCropID and ContentDetailID back in CreativeContentDetailStaging for reference later
					UPDATE a
						SET a.[CreativeCropStagingID] = b.[CreativeCropID],
							a.[ContentDetailID] = b.[CreativeContentDetailID]
					FROM CreativeContentDetailStaging a, CreativeContentDetail b, [CreativeForCropStaging] c
						WHERE c.[LockedByID] = @UserID
						AND a.[CreativeCropStagingID] = c.[CreativeForCropStagingID]
						AND b.[CreativeCropID] = @CreativeCropID
						AND b.[CreativeDetailID] = a.[CreativeDetailID] 
						
			END
		ELSE	--/// For previously cropped Ad select * from CreativeforCropStaging
				BEGIN
					UPDATE CreativeContentDetail
							SET [CreativeDetailID] = a.[CreativeDetailID],
							SellableSpaceCoordX1 = a.SellableSpaceCoordX1,
							SellableSpaceCoordY1 = a.SellableSpaceCoordY1,
							SellableSpaceCoordX2 = a.SellableSpaceCoordX2,
							SellableSpaceCoordY2 = a.SellableSpaceCoordY2,
							SellableSpaceArea = ABS(a.SellableSpaceCoordX2-a.SellableSpaceCoordX1)*ABS(a.SellableSpaceCoordY2-a.SellableSpaceCoordY1)
					FROM CreativeContentDetailStaging a, [CreativeForCropStaging] b, CreativeContentDetail c
							WHERE b.[LockedByID] = @UserID AND a.[CreativeCropStagingID] = b.[CreativeForCropStagingID] AND c.[CreativeContentDetailID] = a.[ContentDetailID] AND b.[CreativeCropID]=@CreativeCropID	
				END

				--CropDetailExclude
				BEGIN
					--/// Remove OLD if any 
					DELETE CreativeDetailExclude		
					FROM CreativeContentDetailStaging a, [CreativeForCropStaging] b, CreativeDetailExclude c
						WHERE b.[LockedByID] = @UserID AND a.[CreativeCropStagingID] = b.[CreativeForCropStagingID] AND c.FK_ContentDetailID = a.[ContentDetailID]	AND b.[CreativeCropID]=@CreativeCropID

					--/// Insert New/Changes
					INSERT INTO CreativeDetailExclude		
							(FK_ContentDetailID,CropRectCoordX1,CropRectCoordY1,CropRectCoordX2,CropRectCoordY2,CropDetailSize,[CreatedDT],[CreatedByID])
					SELECT b.[ContentDetailID],a.CropRectCoordX1,a.CropRectCoordY1,a.CropRectCoordX2,a.CropRectCoordY2,
					ABS(a.CropRectCoordX2-a. CropRectCoordX1)*ABS(a. CropRectCoordY2-a. CropRectCoordY1),CURRENT_TIMESTAMP,@UserID
					FROM CropDetailExcludeStaging a, CreativeContentDetailStaging b, [CreativeForCropStaging] c
					WHERE c.[LockedByID] = @UserID AND b.[CreativeCropStagingID] = c.[CreativeForCropStagingID] AND a.[ContentDetailStagingID] = b.[CreativeContentDetailStagingID] AND c.[CreativeCropID]=@CreativeCropID
				END
				--Crop, CropCategoryGroup & CropDetailInclude 
				BEGIN
					DECLARE @tempTable table
						(
							RowId int IDENTITY(1,1),
							PK_Id int,
							FK_CreativeCropStagingID INT,
							FK_CropID INT,
							DeletedIndicator bit
						)

					INSERT INTO @tempTable(PK_Id,FK_CreativeCropStagingID,FK_CropID,DeletedIndicator) 
					SELECT a.[CompositeCropStagingID],a.[CreativeCropStagingID],a.[CropID],a.[Deleted] FROM CompositeCropStaging a, [CreativeForCropStaging] b 
					WHERE a.[CreativeCropStagingID] = b.[CreativeForCropStagingID]	AND b.[LockedByID] = @UserID AND b.[CreativeCropID]=@CreativeCropID
					
					DECLARE @TopCount INT ,@Counter INT
					SET @TopCount=1
					SELECT @Counter=count(RowId) FROM @tempTable	
					
						WHILE (@Counter>0)
							BEGIN
								DECLARE @CompositeCropStagingID  INT
								DECLARE @CropID  INT
								DECLARE @DeletedIndicator BIT
								SELECT @CompositeCropStagingID = PK_Id, @CropID = FK_CropID, @DeletedIndicator=DeletedIndicator FROM @tempTable WHERE RowId=@TopCount
								--7060,3
								IF (@CropID IS NULL AND @DeletedIndicator = 0)
									BEGIN
										INSERT INTO CompositeCrop
											([CreativeCropID],CompositeImageSize,[CreatedByID],[CreatedDT])
										VALUES (@CreativeCropID,2154,@UserID,CURRENT_TIMESTAMP)
			
										SELECT @CropID = SCOPE_IDENTITY()

										--/// Reflect back the key in the CompositeCropStaging table for reference later
										UPDATE CompositeCropStaging	SET [CropID] = @CropID
											WHERE [CompositeCropStagingID] = @CompositeCropStagingID
									END

								--/// Update CropCategoryGroup for the corresponding Crop								
								DELETE CropCategoryGroup WHERE [CropCategoryGroupID] = @CropID --/// Remove OLD if any
				--select * from CropCategoryGroup where FK_CropID=3
				
								--/// Insert New/Changes
								INSERT INTO CropCategoryGroup		
									([CropCategoryGroupID],[CategoryGroupID],[CreatedByID],[CreateDT])
								SELECT @CropID,a.[CategoryGroupID],@UserID,CURRENT_TIMESTAMP
								FROM CropCategoryGroupStaging a,CompositeCropStaging b
								WHERE a.[CompositeCropStagingID] = b.[CompositeCropStagingID]
								AND b.[Deleted] = 0 AND b.[CompositeCropStagingID]=@CompositeCropStagingID	--/// Exclude deleted in INSERTs

								--/// Update CropDetailInclude for the corresponding Crop select * from CreativeDetailInclude
								DELETE CreativeDetailInclude WHERE FK_CropID = @CropID --/// Remove OLD if any
				
								INSERT INTO CreativeDetailInclude
									(FK_CropID,FK_ContentDetailID,CropRectCoordX1,CropRectCoordY1,CropRectCoordX2,CropRectCoordY2,CropDetailSize,[CreatedDT],[CreatedByID])
								SELECT @CropID,b.[ContentDetailID],a.CropRectCoordX1,a.CropRectCoordY1,a.CropRectCoordX2,a.CropRectCoordY2,
								ABS(a.CropRectCoordX2-a.CropRectCoordX1)*ABS(a.CropRectCoordY2-a.CropRectCoordY1),CURRENT_TIMESTAMP,@UserID
								FROM CropDetailIncludeStaging a, CreativeContentDetailStaging b,CompositeCropStaging c
								WHERE a.[ContentDetailStagingID] = b.[CreativeContentDetailStagingID]
								AND a.[CompositeCropStagingID] = c.[CompositeCropStagingID]
								AND c.[Deleted] = 0 AND c.[CompositeCropStagingID]=@CompositeCropStagingID --/// Exclude deleted in INSERTs

								--/// Reflect newly generated CropID in PromotionMasterStaging for its respective records to be referenced later.
								UPDATE [PromotionStg]
								SET [CompositeCropID] = @CropID
								WHERE [CompositeCropStagingID] = @CompositeCropStagingID
								AND [CompositeCropID] <> NULL AND [CompositeCropStagingID]=@CompositeCropStagingID
								
						select @Counter=@Counter-1
						select @TopCount=@TopCount+1

				END
				END
				--AdPromotion
				BEGIN
					--/// Remove OLD if any
					--/// For the whole Ad
					DELETE AdPromotion
					FROM AdPromotion a, [CreativeForCropStaging] b
					WHERE b.[LockedByID] = @UserID AND a.RecordType = 'A'	AND a.RecordID = b.[CreativeCropID] AND b.[CreativeCropID]=@CreativeCropID
		
					--/// For the full Page
					DELETE AdPromotion
					FROM AdPromotion a, [CreativeForCropStaging] b, CreativeContentDetailStaging c
					WHERE b.[LockedByID] = @UserID AND a.RecordType = 'P'	AND c.[CreativeCropStagingID] = b.[CreativeForCropStagingID] AND a.RecordID = c.[ContentDetailID] AND b.[CreativeCropID]=@CreativeCropID
		
					--/// For the specific Crop (i.e. Composite Image)
					DELETE AdPromotion
					FROM AdPromotion a, [CreativeForCropStaging] b, CompositeCropStaging c
					WHERE b.[LockedByID] = @UserID AND a.RecordType = 'C' AND c.[CreativeCropStagingID] = b.[CreativeForCropStagingID] AND a.RecordID = c.[CropID] AND b.[CreativeCropID]=@CreativeCropID
		
					--/// Insert New/Changes
					--/// For the whole Ad
					INSERT INTO AdPromotion
						(RecordID,RecordType,[AdPromotionID],[CreatedByID],[CreatedDT])			
					SELECT b.[CreativeCropID],'A',a.[PromotionID],@UserID,CURRENT_TIMESTAMP
					FROM AdPromotionStaging a, [CreativeForCropStaging] b
					WHERE b.[LockedByID] = @UserID AND a.RecordType = 'A'	AND a.[RecordStagingID] = b.[CreativeForCropStagingID] AND b.[CreativeCropID]=@CreativeCropID
		
					--/// For the full Page
					INSERT INTO AdPromotion
						(RecordID,RecordType,[AdPromotionID],[CreatedByID],[CreatedDT])
					SELECT c.[ContentDetailID],'P',a.[PromotionID],@UserID,CURRENT_TIMESTAMP
					FROM AdPromotionStaging a, [CreativeForCropStaging] b, CreativeContentDetailStaging c
					WHERE b.[LockedByID] = @UserID AND a.RecordType = 'P'	AND c.[CreativeCropStagingID] = b.[CreativeForCropStagingID] AND a.[RecordStagingID] = c.[ContentDetailID]		
					AND b.[CreativeCropID]=@CreativeCropID

					--/// For the specific Crop (i.e. Composite Image)
					INSERT INTO AdPromotion
						(RecordID,RecordType,[AdPromotionID],[CreatedByID],[CreatedDT])
					SELECT b.[CreativeCropID],'C',a.[PromotionID],@UserID,CURRENT_TIMESTAMP
					FROM AdPromotionStaging a, [CreativeForCropStaging] b, CompositeCropStaging c
					WHERE b.[LockedByID] = @UserID AND a.RecordType = 'C'	AND c.[CreativeCropStagingID] = b.[CreativeForCropStagingID] AND a.[RecordStagingID] = c.[CompositeCropStagingID]
					AND b.[CreativeCropID]=@CreativeCropID
				END
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH 
					  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
					  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
					  RAISERROR ('[sp_InsertAllCRDataFromStagingToMainTbl]: %d: %s',16,1,@error,@message,@lineNo); 
					  ROLLBACK TRANSACTION
	END CATCH 
END