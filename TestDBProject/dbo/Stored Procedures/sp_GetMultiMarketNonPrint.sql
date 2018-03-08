CREATE PROCEDURE sp_GetMultiMarketNonPrint (
	@MarketID int
)
as
begin
	select
		MarketID,
		Descrip
	from Market
	where MarketID = @MarketID
end