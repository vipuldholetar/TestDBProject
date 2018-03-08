/****** Object:  StoredProcedure [dbo].[sp_InsertAdvertiserMarket]    Script Date: 5/9/2016 11:16:27 AM ******/
CREATE PROCEDURE [dbo].[sp_InsertAdvertiserMarket] 
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
	insert into AdvertiserMarket(AdvertiserID, MarketID, AllMarketIndicator) values (@AdvertiserID, @MarketID, @AllMarketIndicator)
END