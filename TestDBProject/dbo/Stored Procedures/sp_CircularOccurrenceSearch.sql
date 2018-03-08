
-- ================================================================================================
-- Author		: Arun Nair 
-- Create date	: 07 May 2015
-- Description	: Search Occurrence for OccurrenceCheckIn 
-- Execution	: sp_CircularOccurrenceSearch
-- Updated By	: Arun Nair on 08/25/2015  -Change in OccurrenceID DataType,Seed Value
--				: Karunakar on 7th Sep 2015
--==================================================================================================

CREATE PROCEDURE [dbo].[sp_CircularOccurrenceSearch]
(
@OccurrenceID AS BIGINT 
)
AS

BEGIN                               
			SET NOCOUNT ON;                                                 
			BEGIN TRY                                   
			--select * from vw_CircularOccurrences
			Select senderName,[OccurrenceDetailCIRID], mediatypeDescription as descrip, marketDescription as description, Publication, 
			EditionName,Language, DistributionDate,AdDate, 
			Advertiser,TradeClass,occurrencecirpriority as Priority, '' AS comments, 
			[AdvertiserID], [MediaTypeID], [MarketID], 
			[PubEditionID], [LanguageID],[EnvelopeID],InternalRefenceNotes,[PatternID],[AdID],
			PageCount,[FlashInd],NationalIndicator,[CreatedByID],Username 
			from vw_CircularOccurrences where [OccurrenceDetailCIRID]=@OccurrenceID
			END TRY 

			BEGIN CATCH 
			DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT
			SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			RAISERROR ('[sp_CircularOccurrenceSearch]: %d: %s',16,1,@error,@message,@lineNo); 
			ROLLBACK TRANSACTION 
			END CATCH 
END
