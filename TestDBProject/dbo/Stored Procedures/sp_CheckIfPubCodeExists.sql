-- =========================================================================
-- Author		: SURESH N
-- Create date	: 1/05/2016
-- Description	: Check PubCode and retrieve Publication Name
-- Execution	: sp_CheckIfPubCodeExists  'ADP'
-- Updated By	:
-- =========================================================================
CREATE PROCEDURE [dbo].[sp_CheckIfPubCodeExists] 
(	
	@PubCode VARCHAR(50)
)
AS
BEGIN
	
	SET NOCOUNT ON;
		BEGIN TRY
			IF EXISTS(SELECT PubCode FROM Publication WHERE PubCode=@PubCode)
			BEGIN
				SELECT PubCode,Descrip AS PublicationName,[PublicationID] As PublicationId FROM Publication WHERE PubCode=@PubCode
			END
		END TRY
		BEGIN CATCH 
		  DECLARE @error INT,@message VARCHAR(4000), @lineNo      INT 
		  SELECT @error = Error_number(),@message = Error_message(),  @lineNo = Error_line();
			  RAISERROR ('[sp_CheckIfPubCodeExists]: %d: %s',16,1,@error,@message,@lineNo); 
		END CATCH 
END
