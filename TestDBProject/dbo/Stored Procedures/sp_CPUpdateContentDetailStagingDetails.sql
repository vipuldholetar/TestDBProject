CREATE PROCEDURE [dbo].[sp_CPUpdateContentDetailStagingDetails] 
	-- Add the parameters for the stored procedure here
	@X1 int,
	@X2 int,
	@Y1 int,
	@Y2 INT,
	@CreativeContentDetailStaging INT,
	@CreativeCropStagingID INT,
	@UserId INT,
	@ContentDetailId INT,
	@CreativeDetailID INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	BEGIN TRY
    -- Insert statements for procedure here
	BEGIN TRANSACTION
	IF(EXISTS(Select [CreativeContentDetailStagingID] from CreativeContentDetailStaging WHERE [CreativeContentDetailStagingID]=@CreativeContentDetailStaging))
		BEGIN
			UPDATE CreativeContentDetailStaging 	
			SET	ContentDetailID=@ContentDetailId,
				[CreativeCropStagingID]=@CreativeCropStagingID,
				--FK_CreativeDetailID='',
				SellableSpaceCoordX1= @X1,
				SellableSpaceCoordY1= @Y1,
				SellableSpaceCoordX2= @X2,
				SellableSpaceCoordY2= @Y2
				WHERE [CreativeContentDetailStagingID]=@CreativeContentDetailStaging
				SELECT @CreativeContentDetailStaging
		END	
		ELSE
		BEGIN
			--DECLARE @CreativeDetailID INT 
		 --   SET @CreativeDetailID = (Select CreativeMasterStagingID from CreativeForCropStaging where CreativeForCropStagingID = @CreativeCropStagingID) 
			
			INSERT INTO CreativeContentDetailStaging (CreativeCropStagingID,SellableSpaceCoordX1,SellableSpaceCoordY1,SellableSpaceCoordX2,SellableSpaceCoordY2,LockedById,LockedDT,CreativeDetailID,ContentDetailID)
			VALUES (@CreativeCropStagingID,@X1,@Y1,@X2,@Y2,@UserId,GETDATE(),@CreativeDetailID,@ContentDetailId)
			SELECT SCOPE_IDENTITY()
		END
	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH 
				  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
				  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				  RAISERROR ('sp_CPUpdateContentDetailStagingDetails: %d: %s',16,1,@error,@message,@lineNo); 
				  ROLLBACK TRANSACTION
	END CATCH 
END