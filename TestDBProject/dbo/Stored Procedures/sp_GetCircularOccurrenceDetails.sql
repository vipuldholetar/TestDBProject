



-- ==================================================================================================
-- Author			:	Arun Nair on 20/05/2015
-- Create date		:
-- Description		:	Select OccurrenceDetails in DPF For Circular
-- Execution Process:  SP_GetCircularOccurrenceDetails 8104
-- Updated By		:   Arun Nair on 08/25/2015  -Change in OccurrenceID DataType,Seed Value		

-- ==================================================================================================

CREATE PROCEDURE [dbo].[sp_GetCircularOccurrenceDetails]
(
@OccurenceID AS BIGINT
)
AS
BEGIN
		BEGIN TRY	
				SELECT OccurrenceID ,Advertiser,TradeClass,CONVERT(VARCHAR,[CommonAdDT],101) AS CommonAdDate,[Event],[Theme],
				[SalesStartDT],[SalesEndDT],Flash,[National],MediaType,Market,[Priority],Color,
				[PageCount],Publication,[Edition], DistributionDate,PubPageNumber,SizingMethod,[MediaStreamId],
				[Source],SubSourceName,[Ethnicity],AdvertiserComments,MediaTypeComments,InternalReferenceNotes,
				FlyerID,EventID,ThemeID,MediatypeID,PublicationID,PubEditionID,SubSourceID,SourceID,PatternMasterID,EnvelopeID,MarketID,CONVERT(VARCHAR,AdDate,101) AS AdDate
				 FROM [dbo].[vw_CircularOccurrenceDetails] Where OccurrenceID=@OccurenceID
		END TRY
		BEGIN CATCH
			   DECLARE	@error   INT, 
						@message VARCHAR(4000), 
						@lineNo  INT 
			  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			  RAISERROR ('[sp_GetCircularOccurrenceDetails]: %d: %s',16,1,@error,@message,@lineNo); 
		END CATCH




END