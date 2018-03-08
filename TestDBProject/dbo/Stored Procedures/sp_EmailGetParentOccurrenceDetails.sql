-- ==================================================================================================
-- Author			:	KARUNAKAR
-- Create date		:	28th October 2015
-- Description		:	Select OccurrenceDetails in DPF For Email
-- Execution Process:   sp_EmailGetParentOccurrenceDetails 3
-- Updated By		: 	
-- ==================================================================================================

CREATE PROCEDURE [dbo].[sp_EmailGetParentOccurrenceDetails]
(
@OccurenceID AS BIGINT
)
AS
BEGIN
		BEGIN TRY	
			SELECT      [OccurrenceDetailEM].[OccurrenceDetailEMID] As OccurrenceID, [OccurrenceDetailEM].[MediaTypeID], [OccurrenceDetailEM].[MarketID], [OccurrenceDetailEM].[AdvertiserEmailID], 
						[OccurrenceDetailEM].[SenderPersonaID], (select LandingURL from LandingPage where LandingPage.LandingPageID = OccurrenceDetailEM.LandingPageID) LandingPageURL, [OccurrenceDetailEM].SubjectLine, [OccurrenceDetailEM].Priority, 
						[OccurrenceDetailEM].[AdDT], [OccurrenceDetailEM].[DistributionDT], [OccurrenceDetailEM].PromotionalInd, SenderPersona.Gender, SenderPersona.AgeBracket, 
						[Pattern].[EventID], [Pattern].[ThemeID], [Pattern].[SalesStartDT], [Pattern].[SalesEndDT],Expectation.Comments as MediaComments
			FROM        [OccurrenceDetailEM] 
			left JOIN  [Pattern] ON [OccurrenceDetailEM].[PatternID] = [Pattern].[PatternID] 
			INNER JOIN SenderPersona ON [OccurrenceDetailEM].[SenderPersonaID] = SenderPersona.[SenderPersonaID]
			Left Join  Ad on  [OccurrenceDetailEM].[AdID]=Ad.[AdID]
			Left join  [dbo].[Expectation] on ad.[AdvertiserID]=Expectation.[RetailerID]
			and Expectation.[MarketID]=[OccurrenceDetailEM].[MarketID] and [OccurrenceDetailEM].[MediaTypeID]=Expectation.[MediaID]
			Where [OccurrenceDetailEM].[OccurrenceDetailEMID]=@OccurenceID
		END TRY
		BEGIN CATCH
			   DECLARE	@error   INT, 
						@message VARCHAR(4000), 
						@lineNo  INT 
			  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			  RAISERROR ('[sp_EmailGetParentOccurrenceDetails]: %d: %s',16,1,@error,@message,@lineNo); 
		END CATCH




END