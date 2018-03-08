CREATE PROCEDURE [dbo].[sp_GetAdvertiserEmail] (
	@AdvertiserID int
)
AS
BEGIN
	SELECT a.MarketID, a.Email, a.AdvertiserEmailID, ad.AdvertiserID,m.Descrip AS MarketDescrip, 
	a.CreatedDT,a.CreatedByID,a.ModifiedByID,a.ModifiedDT
	FROM AdvertiserEmail a left JOIN dbo.Market m ON a.MarketID = m.MarketID
	left JOIN dbo.Advertiser ad ON ad.AdvertiserID = a.AdvertiserID
	WHERE ad.AdvertiserID = @AdvertiserID
END