CREATE PROCEDURE [dbo].[sp_GetTradeClassData]
@AdvertiserId INT
AS
BEGIN
SET NOCOUNT ON;
		BEGIN TRY
			SELECT        TradeClass.TradeClassID, TradeClass.Descrip, Advertiser.AdvertiserID, Advertiser.AdvertiserComments
FROM            TradeClass INNER JOIN
                         Advertiser ON TradeClass.TradeClassID = Advertiser.TradeClassID
WHERE        (Advertiser.AdvertiserID = @AdvertiserID)
		END TRY
		
		BEGIN CATCH 
			  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
			  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			  RAISERROR ('[sp_GetTradeClassData]: %d: %s',16,1,@error,@message,@lineNo); 			  
		END CATCH 
END