CREATE PROCEDURE [dbo].[sp_CPGetCropIDlistFormCreativeCropID] 
	-- Add the parameters for the stored procedure here
	@CreativeCropID INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	BEGIN TRY
    -- Insert statements for procedure here
	select [CompositeCropStagingID] as CropStgID,isnull(cropid,0) cropid from CompositeCropStaging where [CreativeCropStagingID]=@CreativeCropID AND ([Deleted]=0 OR [Deleted] IS NULL)
	END TRY
	BEGIN CATCH
		DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
		SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
		RAISERROR ('[sp_CPGetCropIDlistFormCreativeCropID]: %d: %s',16,1,@error,@message,@lineNo);
		
	END CATCH
END