-- ===========================================================================
-- Author:		Govardhan 
-- Create date: 25 April 2015
-- Description:	Get Language Master data.
-- Updated By		:
--=============================================================================
Create PROCEDURE [dbo].[sp_CPGetLanguages]
AS
BEGIN
		BEGIN TRY
			SELECT LanguageID, Description FROM dbo.[Language]
		END TRY

		BEGIN CATCH
          DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
          SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
          RAISERROR ('[sp_CPGetLanguages]: %d: %s',16,1,@error,@message,@lineNo);           
      END CATCH

END
