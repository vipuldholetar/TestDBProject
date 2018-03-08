-- =============================================================================
-- Author			: Arun Nair 
-- Create date		: 11/26/2015
-- Execution		: 
-- Description		: Validate ReMap of Occurrence in Social Brand
-- Updated By		: 
--					: 
--================================================================================

CREATE PROCEDURE [dbo].[sp_SocialCheckRemapPrimaryOccurrence]
(
@Occurrenceid AS BIGINT
)
AS
BEGIN
    SET NOCOUNT ON;	
	BEGIN TRY
			IF EXISTS (SELECT 1 FROM   Ad INNER JOIN  [OccurrenceDetailSOC]  ON Ad.[PrimaryOccurrenceID]=[OccurrenceDetailSOC].[OccurrenceDetailSOCID] WHERE Ad.[PrimaryOccurrenceID]=@Occurrenceid)
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
			RAISERROR ('[sp_SocialCheckRemapPrimaryOccurrence]: %d: %s',16,1,@error,@message,@lineNo); 			
	END CATCH

END
