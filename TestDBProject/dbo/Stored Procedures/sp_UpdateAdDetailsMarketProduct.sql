CREATE procedure sp_UpdateAdDetailsMarketProduct(
	@AdID int,
	@MarketID int = null,
	@ProductID int
)
as
begin
	update Ad set [TargetMarketId] = @MarketID, ProductId = @ProductID where AdID = @AdID
end