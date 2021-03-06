﻿
-- =============================================
-- Author		:   Arun Nair
-- Create date	:	25 May 2015
-- Description	:   Load Marketdata Values
-- Updated By	:	
--===================================================
CREATE PROCEDURE [dbo].[sp_GetMarketDataForCircularReviewQueue]
AS 
BEGIN
			SET NOCOUNT ON;--Load Circular Review Queue Market Data	
				BEGIN TRY
					SELECT [MarketID],[Descrip] 
					FROM [dbo].[Market] 
					Where [StartDT] <=getdate() AND ([EndDT]>=getdate() OR [EndDT] IS NULL)
					and DisplayInMediaStreams = 1
				END TRY
		BEGIN CATCH
			 DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
			 SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			 RAISERROR ('[sp_GetMarketDataForCircularReviewQueue]: %d: %s',16,1,@error,@message,@lineNo); 
		END CATCH
END