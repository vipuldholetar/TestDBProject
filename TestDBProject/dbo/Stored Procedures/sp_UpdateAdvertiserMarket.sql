/****** Object:  StoredProcedure [dbo].[sp_UpdateAdvertiserMarket]    Script Date: 5/9/2016 11:19:54 AM ******/
CREATE PROCEDURE [dbo].[sp_UpdateAdvertiserMarket] 
	-- Add the parameters for the stored procedure here
	@AdvertiserID int = 0, 
	@MarketID int = 0,
	@AllMarketIndicator bit
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	update AdvertiserMarket
	set MarketID = @MarketID,
	AllMarketIndicator = @AllMarketIndicator
	where AdvertiserID = @AdvertiserID
END