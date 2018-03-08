 CREATE PROCEDURE [dbo].[sp_MultiMapRejectedGeoAndAirDate] 
(
	@OriginalPatternCode varchar(200),
	@AdId  AS INT,
	@Status Varchar(200),
	@MarketId INT, 
	@MINDATE DATETIME,
	@CreatedBy INT
) 
AS
  BEGIN 
      SET NOCOUNT ON
      BEGIN TRY 
       BEGIN TRANSACTION
	    DECLARE @FakePatternCode INT = 0 		
		BEGIN
			INSERT INTO [TVMMPRCode] (OriginalPatternCode,MediaStream,[AdID],ApprovedForAllMarkets,[ApprovedMarketID],Status,[EffectiveEndDT],[EffectiveStartDT],[CreatedDT],[CreatedByID],[ModifiedDT]) 
			VALUES (@OriginalPatternCode,'TV',@AdId,0,@MarketId,@Status,NULL,@MINDATE,GetDate(),@CreatedBy,GetDate())
		END	
	  COMMIT TRANSACTION 
      END TRY
      BEGIN CATCH 
          DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
          SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
          RAISERROR ('[sp_MultiMapGetRejGeoAndAirDate]: %d: %s',16,1,@error,@message,@lineNo)
          ROLLBACK TRANSACTION 
      END CATCH 
  END
