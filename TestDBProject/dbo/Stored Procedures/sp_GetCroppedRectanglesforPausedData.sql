-- =============================================
-- Author:		Monika. J
-- Create date: 11/30/2015
-- Description:	To get all cropped rectangles to display on image
-- Execution:	sp_GetCroppedRectanglesforPausedData 12
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetCroppedRectanglesforPausedData] 
	-- Add the parameters for the stored procedure here
	@CropID INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	BEGIN TRY
    -- Insert statements for procedure here FK_CompositeCropStagingID
	DECLARE @CreativeCropID INT
	DECLARE @CropStgID INT
	DECLARE @CreativeStgCropID INT
	DECLARE @CreativeContentDetailStg INT

	SELECT DISTINCT @CreativeStgCropID=[CreativeCropStagingID] From CompositeCropStaging where [CropID]=@CropID

	SELECT @CreativeContentDetailStg=[CreativeContentDetailStagingID] FROM CreativeContentDetailStaging WHERE [CreativeCropStagingID]=@CreativeStgCropID

	SELECT * FROM CreativeContentDetailStaging WHERE [CreativeCropStagingID]=@CreativeStgCropID

	SELECT --ROW_NUMBER() 
      dense_rank()  OVER (ORDER BY [CompositeCropStagingID]) AS Row,* FROM CropDetailIncludeStaging WHERE [ContentDetailStagingID]=@CreativeContentDetailStg AND [CompositeCropStagingID] IN 
	(select [CompositeCropStagingID] from CompositeCropStaging where [CreativeCropStagingID]=@CreativeStgCropID AND 
	([Deleted]=0 OR [Deleted] IS NULL)) -- by FK_CompositeCropStagingID

	SELECT * FROM CropDetailExcludeStaging WHERE [ContentDetailStagingID]=@CreativeContentDetailStg
	END TRY
	BEGIN CATCH
		DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
		SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
		RAISERROR ('[sp_GetCroppedRectanglesforPausedData]: %d: %s',16,1,@error,@message,@lineNo);
		
	END CATCH
END
