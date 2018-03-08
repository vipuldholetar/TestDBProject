CREATE PROCEDURE [dbo].[sp_GetOccurenceMediaType] (
	@MediaType varchar(50)
)
AS
BEGIN
	SELECT OccurenceMediaTypeID
	 
	FROM OccurenceMediaType 
	WHERE MediaType = @MediaType
END