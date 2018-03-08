-- ==================================================================================================
-- Author			:	KARUNAKAR
-- Create date		:	12th November 2015
-- Description		:	Select OccurrenceDetails in DPF For WebSite
-- Execution Process:   sp_WebsiteGetOccurrenceDetails 1123
-- Updated By		: 	
-- ==================================================================================================

CREATE PROCEDURE [dbo].[sp_WebsiteGetOccurrenceDetails]
(
@OccurenceID AS BIGINT
)
AS
BEGIN
		BEGIN TRY	
			SELECT      [OccurrenceDetailWEB].[OccurrenceDetailWEBID] As OccurrenceID, [OccurrenceDetailWEB].[MediaTypeID], [OccurrenceDetailWEB].[MarketID], 						
						[OccurrenceDetailWEB].[AdDT], [OccurrenceDetailWEB].[DistributionDT], 
						[Pattern].[EventID], [Pattern].[ThemeID],Expectation.Comments as MediaComments	
			FROM        [OccurrenceDetailWEB] 
			left JOIN  [Pattern] ON [OccurrenceDetailWEB].[PatternID] = [Pattern].[PatternID] 
			Inner Join  Ad on  [OccurrenceDetailWEB].[AdID]=Ad.[AdID]
			Left join  [dbo].[Expectation] on ad.[AdvertiserID]=Expectation.[RetailerID]
			and  [OccurrenceDetailWEB].[MediaTypeID]=Expectation.[MediaID]
			Where [OccurrenceDetailWEB].[OccurrenceDetailWEBID]=@OccurenceID
		END TRY
		BEGIN CATCH
			   DECLARE	@error   INT, 
						@message VARCHAR(4000), 
						@lineNo  INT 
			  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			  RAISERROR ('[sp_WebsiteGetOccurrenceDetails]: %d: %s',16,1,@error,@message,@lineNo); 
		END CATCH




END
