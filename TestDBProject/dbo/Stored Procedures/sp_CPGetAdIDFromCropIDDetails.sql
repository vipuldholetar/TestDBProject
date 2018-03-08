-- =============================================
-- Author:		Monika. J
-- Create date: 04-01-15
-- Description:	<Description,,> Test Category Name
-- sp_CPGetAdIDFromCropIDDetails 2,'Test Category Name'
-- =============================================
CREATE PROCEDURE sp_CPGetAdIDFromCropIDDetails 
	-- Add the parameters for the stored procedure here
	@Val INT,	
	@ID varchar(max)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	If(@Val=1)
	SELECT [CreativeID] as ID from CompositeCrop a INNER JOIN [CreativeForCrop] b ON b.[CreativeForCropID]=a.[CreativeCropID] where a.[CompositeCropID]=@ID
	ELSE IF(@Val=2)
	SELECT [RefCategoryID] as ID FROM RefCategory where CategoryName=@ID

END
