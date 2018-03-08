


-- ===========================================================================
-- Author			: Arun Nair 
-- Create date		: 12/30/2015
-- Description		: Load All Publication
-- Updated By		: 
--=============================================================================
CREATE PROCEDURE [dbo].[sp_LoadPublicationMultiEdition]
AS
BEGIN
	SET NOCOUNT ON;		
		  BEGIN TRY
				SELECT DISTINCT [PublicationID] As PublicationId,Descrip AS PublicationName FROM PUBLICATION 
		  END TRY
		  BEGIN CATCH
			  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
			  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			  RAISERROR ('[sp_LoadPublicationMultiEdition]: %d: %s',16,1,@error,@message,@lineNo);           
		  END CATCH
END
