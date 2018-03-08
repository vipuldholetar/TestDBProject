
CREATE FUNCTION ufn_ConORDurable (@MediaTypeID int,@MarketID int,@AdvertiserID int)
RETURNS Varchar
AS
	BEGIN
		DECLARE @Consumable int
		DECLARE @Durable int
		SELECT @Consumable = MAX(FVReqInd) FROM Expectation WHERE [MediaID] = @MediaTypeID AND [MarketID] = @MarketID AND [RetailerID] = @AdvertiserID

		SELECT @Durable = MAX(ADReqInd) FROM Expectation WHERE [MediaID] = @MediaTypeID AND [MarketID] = @MarketID AND [RetailerID] = @AdvertiserID

		DECLARE @Value VARCHAR (10)
		SET  @Value = ''
		IF @Consumable = 1 
			SET @Value = @Value + 'C'
		ELSE IF @Durable = 1 
			SET @Value = @Value + 'D'

		RETURN (@Value)
	END
