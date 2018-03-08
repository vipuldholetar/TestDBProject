-- ===========================================================================
-- Author			:Ramesh Bangi
-- Create date		:10/27/2015
-- Description		:Get  Tradeclass 
-- Updated By		:
--=============================================================================

CREATE PROCEDURE [dbo].[sp_WebsiteLoadTradeclass]
AS
BEGIN
SET NOCOUNT ON;
		BEGIN TRY
			SELECT [TradeClassID],Descrip FROM [TradeClass] ORDER BY Descrip ASC
		END TRY
		
		BEGIN CATCH 
			  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
			  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			  RAISERROR ('[sp_WebsiteLoadTradeclass]: %d: %s',16,1,@error,@message,@lineNo); 			  
		END CATCH 
END
