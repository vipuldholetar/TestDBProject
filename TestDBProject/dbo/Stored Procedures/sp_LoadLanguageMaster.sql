
-- ===========================================================================
-- Author		:Arun Nair 
-- Create date	:12 Aug 2015
-- Description	:Get Language Details
-- Updated By	:Arun Nair on 08/11/2015 - CleanUp for OneMTDB 
--				:Arun Nair on 12/02/2015 - Added Ethniccode to Query
--=============================================================================
CREATE PROCEDURE [dbo].[sp_LoadLanguageMaster]
AS
BEGIN
SET NOCOUNT ON;

		BEGIN TRY
			SELECT LanguageID, [Description],[EthnicGroupID] FROM dbo.[Language]
		END TRY
		BEGIN CATCH 
			  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
			  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			  RAISERROR ('[sp_LoadLanguageMaster]: %d: %s',16,1,@error,@message,@lineNo); 
		 END CATCH 
END
