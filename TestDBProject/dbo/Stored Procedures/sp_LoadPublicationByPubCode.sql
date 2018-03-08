


-- ===========================================================================
-- Author			: Ashanie Cole 
-- Create date		: 11/02/2016
-- Description		: Load Publication by PubCode
-- Updated By		: 
--=============================================================================
CREATE PROCEDURE [dbo].[sp_LoadPublicationByPubCode]
    @PubCode varchar(20)
AS
BEGIN
	SET NOCOUNT ON;		
		  BEGIN TRY
				SELECT DISTINCT [PublicationID] As PublicationId,Descrip AS PublicationName
				FROM PUBLICATION 
				WHERE ISNULL(PubCode,CTLegacyPubCode) = @PubCode
		  END TRY
		  BEGIN CATCH
			  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
			  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			  RAISERROR ('[sp_LoadPublicationByPubCode]: %d: %s',16,1,@error,@message,@lineNo);           
		  END CATCH
END