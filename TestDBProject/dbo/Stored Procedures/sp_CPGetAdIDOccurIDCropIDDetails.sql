-- =============================================
-- Author:		Monika. J
-- Create date: 12/29/15
-- Description:	To get ad/Occurrence/CropID value
-- sp_CPGetAdIDOccurIDCropIDDetails 1,7346,'PUBLICATION'
-- 7346,2038,3
-- =============================================
CREATE PROCEDURE sp_CPGetAdIDOccurIDCropIDDetails 
	-- Add the parameters for the stored procedure here
	@Val int,
	@ID int,
	@MediaType nvarchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements. select * from Creativeforcrop
	DECLARE @MediaVal nvarchar(max)
	SELECT @MediaVal=Value  FROM   [dbo].[Configuration] WHERE ValueTitle=@MediaType
	SET NOCOUNT ON;
	if(@Val=1)
		BEGIN		
			SELECT [OccurrenceID] as ID from [CreativeForCrop] where [CreativeID]=@ID AND MediaStream=@MediaVal
		END
	ELSE IF(@Val=2)
		BEGIN
			SELECT [CreativeID] as ID from [CreativeForCrop] where [OccurrenceID]=@ID AND MediaStream=@MediaVal
		END
	ELSE IF(@Val=3)
		BEGIN
			SELECT a.[CreativeID] as ID,a.[OccurrenceID] as ID_Occ from [CreativeForCrop] a INNER JOIN CompositeCrop b ON b.[CreativeCropID]=a.[CreativeForCropID] 
			where b.[CompositeCropID]=@ID AND a.MediaStream=@MediaVal
		END
END
