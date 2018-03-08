/****** Object:  StoredProcedure [dbo].[sp_DeleteAdvertiserMarket]    Script Date: 5/9/2016 10:50:49 AM ******/
CREATE PROCEDURE [dbo].[sp_DeleteAdvertiserMarket](
	@AdvertiserID int,
	@MarketId INT
)
as
begin
	delete from AdvertiserMarket
	where AdvertiserID = @AdvertiserID
	AND MarketID = @MarketId
end