CREATE PROCEDURE [dbo].[sp_GetAdvertiserMarket] (
	@AdvertiserID int
)
AS
BEGIN
	SELECT am.AdvertiserID, m.MarketID, m.Descrip, AllMarketIndicator
	FROM AdvertiserMarket am Left join Market m on am.MarketID = m.MarketID
	WHERE AdvertiserID = @AdvertiserID
END