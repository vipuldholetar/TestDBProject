CREATE PROCEDURE [dbo].[sp_RemoveLastRectangle] 
	@x1 INT,
	@y1 INT,
	@width int,
	@height int,
	@type varchar(50),
	@id int
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

	if @type = 'Sellable'
	begin
		delete from	CreativeContentDetailStaging where [SellableSpaceCoordX1] = @x1 and [SellableSpaceCoordY1] = @y1 and [SellableSpaceCoordX2] = @width and [SellableSpaceCoordY2] = @height and [CreativeContentDetailStagingID] = @id
	end

	if @type = 'Exclude'
	begin
	   delete from CropDetailExcludeStaging where [CropRectCoordX1] = @x1 and [CropRectCoordY1] = @y1 and [CropRectCoordX2] = @width and [CropRectCoordY2] = @height and [ContentDetailStagingID] = @id
	end

	if @type = 'Include'
	begin
		delete from CropDetailIncludeStaging where [CropRectCoordX1] = @x1 and [CropRectCoordY1] = @y1 and [CropRectCoordX2] = @width and [CropRectCoordY2] = @height and [ContentDetailStagingID] = @id
	end

	END TRY
	BEGIN CATCH
		DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
		SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
		RAISERROR ('[sp_RemoveLastRectangle]: %d: %s',16,1,@error,@message,@lineNo);
		
	END CATCH
END