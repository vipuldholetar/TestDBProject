
-- ===========================================================================
-- Author		:Arun Nair 
-- Create date	:12/02/2015
-- Description	:Get Ethnicity
-- Updated By	:
--=============================================================================
CREATE PROCEDURE [dbo].[sp_LoadEthnicity]
AS
BEGIN
SET NOCOUNT ON;

		BEGIN TRY
			SELECT [RefEthnicGroupID],EthnicGroupName,[CTLegacyLanguageID] FROM [dbo].[RefEthnicGroup]
		END TRY
		BEGIN CATCH 
			  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
			  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			  RAISERROR ('[sp_LoadEthnicity]: %d: %s',16,1,@error,@message,@lineNo); 
		 END CATCH 

END