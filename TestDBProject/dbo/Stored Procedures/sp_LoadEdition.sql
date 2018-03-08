
-- ============================================================================
-- Author			: Arun Nair 
-- Create date		: 09/29/2015
-- Description		: Get Exception Market
-- Execution Process: [sp_LoadEdition]10
-- Updated By		: 
-- =============================================================================

CREATE PROCEDURE [dbo].[sp_LoadEdition]
(
@PublicationId AS INT
)
AS
SET NOCOUNT ON;
BEGIN
	BEGIN TRY		
		SELECT pe.EditionName,p.[PublicationID],pe.[PubEditionID],Descrip
		--,startdt,publication.enddt  
		From Publication p INNER JOIN PubEdition pe  ON p.[PublicationID]=pe.[PublicationID] 
		--WHERE publication.startdt<=GETDATE() and publication.enddt>=GETDATE()
		AND p.[PublicationID] = @PublicationId
	END TRY
	BEGIN CATCH 
		DECLARE @error   INT,@message VARCHAR(4000), @lineNo  INT 
		SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line()
		RAISERROR ('[sp_LoadPublication]: %d: %s',16,1,@error,@message,@lineNo); 
	END CATCH 
END
