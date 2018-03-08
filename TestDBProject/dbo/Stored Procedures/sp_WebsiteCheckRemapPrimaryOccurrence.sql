-- =============================================================================
-- Author			: Arun Nair 
-- Create date		: 11/02/2015
-- Execution		: 
-- Description		: Validate ReMap of PrimaryOccurrence
-- Updated By		: 
--					: 
--================================================================================

CREATE PROCEDURE [dbo].[sp_WebsiteCheckRemapPrimaryOccurrence]
(
@ParentOccurrenceid AS BIGINT
)
AS
BEGIN
    SET NOCOUNT ON;	
	BEGIN TRY
			IF EXISTS (SELECT * FROM   Ad INNER JOIN  [OccurrenceDetailWEB]  ON Ad.[PrimaryOccurrenceID]=[OccurrenceDetailWEB].[OccurrenceDetailWEBID] WHERE Ad.[PrimaryOccurrenceID]=@ParentOccurrenceid)
				BEGIN
					SELECT 0 AS Result  -- ReMap Not Possible 
				END
			ELSE
				BEGIN
					SELECT 1  AS Result -- ReMap Possible 
				END 
	END TRY

	BEGIN CATCH
			DECLARE @error INT,@message     VARCHAR(4000),@lineNo      INT 
			SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			RAISERROR ('[sp_WebsiteCheckRemapPrimaryOccurrence]: %d: %s',16,1,@error,@message,@lineNo); 			
	END CATCH

END
