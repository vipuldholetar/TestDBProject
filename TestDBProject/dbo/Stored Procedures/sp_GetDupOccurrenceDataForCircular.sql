
CREATE PROCEDURE [dbo].[sp_GetDupOccurrenceDataForCircular]

	@pMediaTypeID int,

	@pAdvertiserID int,

	@pPublicationID int,

	@pMarketID int,

	@pPubEditionID int,
	@pAdDate Date,
	@pNumberOfdays int

AS

BEGIN

	SET NOCOUNT ON;

		BEGIN TRY

				BEGIN TRANSACTION 
				
SELECT        [OccurrenceDetailCIRID] as OccurrenceID, advertiser as Advertiser,[LanguageID]  , AdDate, MediaTypeDescription as MediaType, 

                         event , theme , MarketDescription as Market,  Publication, [SalesStartDT], 

                         [SalesEndDT], PageCount,TradeClass, CouponIndicator as Coupon, 

                        username, [CreatedDT],OccurrencecirPriority, event,theme, language

FROM           vw_CircularOccurrences

						where [MediaTypeID] =@pMediaTypeID and

[AdvertiserID]=@pAdvertiserID and [MarketID]=@pMarketID and [LanguageID]=(select distinct [LanguageID] from pubedition where [PubEditionID]=@pPubEditionID)
and AdDate>=cast(DateAdd(Day,-@pnumberofDays,@padDate) as date) and AdDate<=cast(dateadd(Day,@pNumberOfdays,@padDate) as date)

and [PublicationID]= @pPublicationID

				END TRY 

				BEGIN CATCH 

          DECLARE @error   INT, 

                  @message VARCHAR(4000), 

                  @lineNo  INT 



          SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 

          RAISERROR ('sp_GetDupOccurrenceDataForCircular: %d: %s',16,1,@error,@message,@lineNo); 



      END CATCH 			



END
