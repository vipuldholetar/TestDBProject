
-- ===========================================================================
-- Author		:Arun Nair 
-- Create date	:12/02/2015
-- Description	:Get Ethinicity
-- Updated By	:
--=============================================================================
CREATE PROCEDURE [dbo].[sp_LoadEthinicity]
AS
BEGIN
SET NOCOUNT ON;

		BEGIN TRY
			SELECT [RefEthinicGroupID],EthnicGroupName,[CTLegacyLanguageID] FROM [dbo].[RefEthinicGroup]
		END TRY
		BEGIN CATCH 
			  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
			  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			  RAISERROR ('[sp_LoadEthinicity]: %d: %s',16,1,@error,@message,@lineNo); 
		 END CATCH 

END
