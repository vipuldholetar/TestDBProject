CREATE PROCEDURE [dbo].[sp_PEFGetCroppedRectanglesforPrmo] 
	-- Add the parameters for the stored procedure here
	@CropID INT,
	@ContentDetail INT
AS
BEGIN

--SELECT b.FK_CreativeDetailID,
--a.CropRectCoordX1, 
--a.CropRectCoordY1, 
--a.CropRectCoordX2, 
--a.CropRectCoordY2
--FROM CreativeDetailInclude a, CreativeContentDetail b
--WHERE a.FK_CropID = @CropID
--AND b.PK_ID = a.FK_ContentDetailID


	--DECLARE @CreativeCropID INT
	----DECLARE @Crop_ID INT	
	--DECLARE @CreativeContentDetail INT	

	--SELECT DISTINCT @CreativeCropID=[CreativeCropID] From CompositeCrop where [CompositeCropID]=@CropID

	--SELECT @CreativeContentDetail=[CreativeContentDetailID] FROM CreativeContentDetail WHERE [CreativeCropID]=@CreativeCropID

	--SELECT * FROM CreativeContentDetail WHERE [CreativeCropID]=@CreativeCropID

	--SELECT * FROM CreativeDetailInclude WHERE FK_ContentDetailID=@CreativeContentDetail AND FK_CropID = @CropID	

	--SELECT * FROM CreativeDetailExclude WHERE FK_ContentDetailID=@CreativeContentDetail


	
	
	SELECT * FROM CreativeContentDetail WHERE CreativeContentDetailID = @ContentDetail

	SELECT * FROM CreativeDetailInclude WHERE FK_ContentDetailID=@ContentDetail AND FK_CropID = @CropID	

	SELECT * FROM [CreativeDetailExclude] WHERE [FK_ContentDetailID] = @ContentDetail



end