CREATE PROCEDURE [dbo].[sp_PublicationDPFGetExpectationPriority]
	@pAdvertiserID int,
	@pMarketID int,
	@pMediaTypeID int
AS
BEGIN
	
SET NOCOUNT ON;
			SELECT        Priority,Comments 
FROM            Expectation
WHERE        ([RetailerID] = @pAdvertiserID) AND ([MarketID] = @pMarketID) AND ([MediaID] = @pMediaTypeID)	
    
END
