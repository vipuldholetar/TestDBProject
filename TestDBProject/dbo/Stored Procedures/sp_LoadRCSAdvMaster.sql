-- ===========================================================================
-- Author			:Arun Nair 
-- Create date		:12 Aug 2015
-- Description		:Get  RCSAdvertiserMaster Values
-- Updated By		:Arun Nair on 08/11/2015 - CleanUp for OneMTDB 
--=============================================================================

CREATE PROCEDURE [dbo].[sp_LoadRCSAdvMaster]
AS
BEGIN
SET NOCOUNT ON;
		BEGIN TRY
			SELECT [RCSAdvID] AS RCSAdvertiserID, Name AS RCSAdvertiserName FROM [RCSAdv] ORDER BY [RCSAdvID] DESC
		END TRY
		
		BEGIN CATCH 
			  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
			  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			  RAISERROR ('[sp_LoadRCSAdvMaster]: %d: %s',16,1,@error,@message,@lineNo); 			  
		END CATCH 
END
