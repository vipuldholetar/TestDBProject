-- =============================================
-- Author		:   Ramesh Bangi
-- Create date	:	11/20/2015
-- Description	:   Load Marketdata Values
--Execution		:   [dbo].[sp_WebsiteReviewMarketData]
-- Updated By	:	
--===================================================
CREATE PROCEDURE [dbo].[sp_WebsiteReviewMarketData]
AS 
BEGIN
			SET NOCOUNT ON;--Load Website Review Queue Market Data	
				BEGIN TRY
					SELECT [MarketID],[Descrip] FROM [dbo].[Market] Where [StartDT] <=getdate() AND [EndDT]>=getdate() OR [EndDT] IS NULL
				END TRY
		BEGIN CATCH
			 DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
			 SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			 RAISERROR ('[sp_WebsiteReviewMarketData]: %d: %s',16,1,@error,@message,@lineNo); 
		END CATCH
END
