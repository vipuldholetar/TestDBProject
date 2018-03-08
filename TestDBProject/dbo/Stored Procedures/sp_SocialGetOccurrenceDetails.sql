-- ==================================================================================================
-- Author			:	Arun Nair
-- Create date		:	23th Nov 2015
-- Description		:	Select OccurrenceDetails in DPF For Social
-- Execution Process:   sp_SocialGetOccurrenceDetails 25
-- Updated By		: 	
-- ==================================================================================================

CREATE PROCEDURE [dbo].[sp_SocialGetOccurrenceDetails]
(
@OccurenceID AS BIGINT
)
AS
BEGIN
		BEGIN TRY	
			SELECT      [OccurrenceDetailSOC].[OccurrenceDetailSOCID] As OccurrenceID, [OccurrenceDetailSOC].[MediaTypeID], [OccurrenceDetailSOC].[MarketID],
						[OccurrenceDetailSOC].SocialType,[OccurrenceDetailSOC].LandingPageURL,
						[OccurrenceDetailSOC].URL,[OccurrenceDetailSOC].SubjectPost, [OccurrenceDetailSOC].Priority,[OccurrenceDetailSOC].[AdDT], [OccurrenceDetailSOC].[DistributionDT],
						[OccurrenceDetailSOC].CountryOrigin,[OccurrenceDetailSOC].FormatCode,[OccurrenceDetailSOC].RatingCode,[OccurrenceDetailSOC].RelationshiptoAdv,
						[OccurrenceDetailSOC].PromotionalInd,[OccurrenceDetailSOC].AssignedtoOffice,
						[Pattern].[EventID], [Pattern].[ThemeID], [Pattern].[SalesStartDT], [Pattern].[SalesEndDT],Expectation.Comments as MediaComments
			FROM        [OccurrenceDetailSOC] 
			INNER JOIN  [Pattern] ON [OccurrenceDetailSOC].[PatternID] = [Pattern].[PatternID] 			
			LEFT JOIN  Ad on  [OccurrenceDetailSOC].[AdID]=Ad.[AdID]	
			Left join  [dbo].[Expectation] on ad.[AdvertiserID]=Expectation.[RetailerID]
			and Expectation.[MarketID]=[OccurrenceDetailSOC].[MarketID] and [OccurrenceDetailSOC].[MediaTypeID]=Expectation.[MediaID]
					
			WHERE [OccurrenceDetailSOC].[OccurrenceDetailSOCID]=@OccurenceID
		END TRY
		BEGIN CATCH
			  DECLARE	@error   INT,@message VARCHAR(4000),@lineNo  INT 
			  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			  RAISERROR ('[sp_SocialGetOccurrenceDetails]: %d: %s',16,1,@error,@message,@lineNo); 
		END CATCH




END
