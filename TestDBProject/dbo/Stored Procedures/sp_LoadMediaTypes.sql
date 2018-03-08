
-- ============================================================================
-- Author			: Arun Nair 
-- Create date		: 09/25/2015
-- Description		: Get Exception Media Type
-- Execution Process: [sp_LoadMediaTypes] 'CIR'
-- Updated By		: Arun Nair On 09/29/2015 - Added MediaStreamId Param
-- =============================================================================

CREATE PROCEDURE [dbo].[sp_LoadMediaTypes]
(
@MediaStreamId AS NVARCHAR(MAX)
)
AS
SET NOCOUNT ON;
BEGIN
	BEGIN TRY
		SELECT Descrip,[MediaTypeID] FROM MediaType WHERE MediaStream = @MediaStreamId AND IndDisplayValue = 1 ORDER BY 1
	END TRY
	BEGIN CATCH 
		DECLARE @error   INT,@message VARCHAR(4000), @lineNo  INT 
		SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line()
		RAISERROR ('[sp_LoadMediaTypes]: %d: %s',16,1,@error,@message,@lineNo); 
	END CATCH 
END
