CREATE Procedure [dbo].[sp_PublicationDPFGetOccurrenceDetails]

(

@OccurrenceId As BigInt

)

As 

BEGIN

			 BEGIN TRY 

				 Select  [OccurrenceDetailPUBID],Advertiser,OccurrencePriority,TradeClass,[AdDT],[EventID],[ThemeID],[SalesStartDT],

				 [SalesEndDT],[FlashInd],NationalIndicator,[MediaTypeID],[MarketID],Color,PageCount,Publication,EditionName,IssueDate,MediaStream As MediaStreamID,

				 [SubSourceID],LanguageName,InternalRefenceNotes,SizingMethod,SourceDescription,[PublicationID],[SizeID],[PubSectionID],Size,PubType,PubPageNumber from vw_PublicationOccurrenceData where [OccurrenceDetailPUBID]=@OccurrenceId

			 End TRY

			 BEGIN CATCH

				DECLARE @error   INT,@message VARCHAR(4000), @lineNo  INT 

				SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 

				RAISERROR ('sp_PublicationDPFOccurrenceDetail: %d: %s',16,1,@error,@message,@lineNo)   ; 

				ROLLBACK TRANSACTION 

			END CATCH

END