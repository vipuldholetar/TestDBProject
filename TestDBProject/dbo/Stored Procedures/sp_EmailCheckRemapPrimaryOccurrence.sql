
-- =============================================================================
-- Author			: Arun Nair 
-- Create date		: 11/02/2015
-- Execution		: 
-- Description		: Validate ReMap of PrimaryOccurrence
-- Updated By		: 
--					: 
--================================================================================

CREATE PROCEDURE sp_EmailCheckRemapPrimaryOccurrence
(
@ParentOccurrenceid AS BIGINT
)
AS
BEGIN
    SET NOCOUNT ON;	
	BEGIN TRY
			IF EXISTS (SELECT * FROM   Ad INNER JOIN  [OccurrenceDetailEM]  ON Ad.[PrimaryOccurrenceID]=[OccurrenceDetailEM].[OccurrenceDetailEMID] WHERE Ad.[PrimaryOccurrenceID]=@ParentOccurrenceid)
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
			RAISERROR ('[sp_EmailCheckRemapPrimaryOccurrence]: %d: %s',16,1,@error,@message,@lineNo); 			
	END CATCH

END