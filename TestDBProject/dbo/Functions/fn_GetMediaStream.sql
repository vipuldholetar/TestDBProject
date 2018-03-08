-- =============================================
-- Author:		SURESH N
-- Create date: 07/12/2015
-- Description:	Get Media stream using Occurance ID
-- Execution :  SELECT OneMT_12062015.dbo.fn_GetMediaStream(500) AS Result
-- =============================================
CREATE FUNCTION [dbo].[fn_GetMediaStream] 
(
	-- Add the parameters for the function here
	@OccurrenceID BIGINT
)
RETURNS VARCHAR(20)
AS
BEGIN
	--declare @occurrenceID int = 1110300
	declare @mediaTypeID int
	declare @mediaType varchar(20) = ''

	select @mediaTypeID = MediaTypeID
	from OccurrenceDetailCIR
	where OccurrenceDetailCIRID = @occurrenceID

	select @mediaTypeID = MediaTypeID
	from OccurrenceDetailEM
	where OccurrenceDetailEMID = @occurrenceID

	select @mediaTypeID = MediaTypeID
	from OccurrenceDetailPUB
	where OccurrenceDetailPUBID = @occurrenceID

	select @mediaTypeID = MediaTypeID
	from OccurrenceDetailSOC
	where OccurrenceDetailSOCID = @occurrenceID

	select @mediaTypeID = MediaTypeID
	from OccurrenceDetailWEB
	where OccurrenceDetailWEBID = @occurrenceID

	--print('MediaTypeID = ' + cast(@mediaTypeID as varchar(10)))

	select @mediaType = MediaStream
	from MediaType
	where MediaTypeID = @mediaTypeID

	--print('MediaType = ' + @mediaType)

	return @mediaType
END