/****** Object:  StoredProcedure [dbo].[sp_GetOccurrenceMediaType]    Script Date: 6/6/2016 5:02:32 PM ******/
CREATE PROCEDURE [dbo].[sp_GetOccurrenceMediaType] (
	@MediaType varchar(50)
)
AS
BEGIN
	SELECT OccurrenceMediaTypeID
	 
	FROM OccurrenceMediaType 
	WHERE MediaType = @MediaType
END