-- ===========================================================================
-- Author			:Arun Nair
-- Create date		:11/17/2015
-- Description		:Get  OfficeLocation 
-- Updated By		:
--=============================================================================

CREATE PROCEDURE [dbo].[sp_LoadOfficeLocation]
AS
BEGIN
SET NOCOUNT ON;
		BEGIN TRY
			SELECT Descrip AS OfficeLocation 
			FROM [Code] WHERE CodeTypeId = 8
			ORDER BY Descrip ASC
		END TRY		
		BEGIN CATCH 
			  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
			  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			  RAISERROR ('[sp_LoadOfficeLocation]: %d: %s',16,1,@error,@message,@lineNo); 			  
		END CATCH 
END