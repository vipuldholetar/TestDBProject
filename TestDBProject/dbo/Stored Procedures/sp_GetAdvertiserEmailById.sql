CREATE PROCEDURE [dbo].[sp_GetAdvertiserEmailById] (
	@AdvertiserEmailID int
)
AS
BEGIN
	SELECT a.MarketID, a.Email, a.AdvertiserEmailID, ad.AdvertiserID,m.Descrip AS MarketDescrip, 
	a.CreatedDT,a.CreatedByID,a.ModifiedByID,a.ModifiedDT
	FROM AdvertiserEmail a left JOIN dbo.Market m ON a.MarketID = m.MarketID
	left JOIN dbo.Advertiser ad ON ad.AdvertiserID = a.AdvertiserID
	WHERE a.AdvertiserEmailID = @AdvertiserEmailID
END