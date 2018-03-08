-- ===========================================================================
-- Author			:Arun Nair 
-- Create date		:14 Aug 2015
-- Description		:Get  Users 
-- Updated By		:
--=============================================================================

CREATE PROCEDURE [dbo].[sp_LoadUsers]
AS
BEGIN
SET NOCOUNT ON;
		BEGIN TRY
			SELECT USERID,USERNAME,FNAME+' '+LNAME AS UNAME,[ActiveInd] FROM [USER] 
			WHERE [ActiveInd]=1 ORDER BY UNAME ASC
		END TRY
		
		BEGIN CATCH 
			  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
			  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			  RAISERROR ('[sp_LoadUsers]: %d: %s',16,1,@error,@message,@lineNo); 			  
		END CATCH 
END
