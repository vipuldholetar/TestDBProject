
-- =============================================
-- Author		:   Arun Nair
-- Create date	:	07/03/2015
-- Description	:   Load Marketdata Values
-- Updated By	:	
--===================================================
CREATE PROCEDURE [dbo].[sp_GetMarketDataForOutdoorWorkQueue]
AS 
BEGIN
			SET NOCOUNT ON;
				BEGIN TRY
			--SELECT [MarketID],[Descrip] 
			--FROM [dbo].[Market] 
			--where DisplayInMediaStreams = 1
			--order by Descrip
			SELECT M.[MarketID],M.[Descrip] 
			FROM [dbo].[Market] M 
			INNER JOIN MarketMediaStream S ON S.MarketID=M.MarketID
			INNER JOIN CONFIGURATION C ON C.CONFIGURATIONID=S.MEDIASTREAMID
			where C.VALUE='OD' AND COMPONENTNAME='Media Stream'
			order by Descrip
				END TRY
		BEGIN CATCH
			 DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
			 SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			 RAISERROR ('[sp_GetMarketDataForOutdoorWorkQueue]: %d: %s',16,1,@error,@message,@lineNo); 
		END CATCH
END