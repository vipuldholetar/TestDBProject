CREATE PROCEDURE [dbo].[sp_GetOccrncDataForBulkUpdateEmail] 
(
@OccurrenceList As NVARCHAR(max)
)
AS
BEGIN
	SET NOCOUNT ON
			BEGIN TRY
					SELECT      [OccurrenceDetailEM].[OccurrenceDetailEMID] As OccurrenceID, 
								[OccurrenceDetailEM].[MediaTypeID],
								[OccurrenceDetailEM].[MarketID], 
								(select LandingURL from LandingPage where LandingPage.LandingPageID = OccurrenceDetailEM.LandingPageID) LandingPageURL,
								[OccurrenceDetailEM].[AdvertiserEmailID], 
								[OccurrenceDetailEM].[SenderPersonaID], 
								[OccurrenceDetailEM].[DistributionDT],
								[OccurrenceDetailEM].[AdDT],
								[OccurrenceDetailEM].SubjectLine,
								[Pattern].[EventID], 
								[Pattern].[ThemeID],		
								[Pattern].[SalesStartDT], 
								[Pattern].[SalesEndDT],
								[OccurrenceDetailEM].PromotionalInd, 
								'Edit' as PageDefination,
								[Pattern].PatternId
			FROM        [OccurrenceDetailEM] 
			left JOIN  [Pattern] ON [OccurrenceDetailEM].[PatternID] = [Pattern].[PatternID] 
			INNER JOIN SenderPersona ON [OccurrenceDetailEM].[SenderPersonaID] = SenderPersona.[SenderPersonaID]
			Left Join  Ad on  [OccurrenceDetailEM].[AdID]=Ad.[AdID]
			Left join  [dbo].[Expectation] on ad.[AdvertiserID]=Expectation.[RetailerID]
			and Expectation.[MarketID]=[OccurrenceDetailEM].[MarketID] and [OccurrenceDetailEM].[MediaTypeID]=Expectation.[MediaID]
							WHERE [OccurrenceDetailEMID] in (select * from dbo.fn_CSVToTable(@OccurrenceList))
			END TRY 
			BEGIN CATCH
				  DECLARE @error INT,@message VARCHAR(4000),@lineNo  INT 
				  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line()
				  RAISERROR ('[sp_GetOccrncDataForBulkUpdateEmail]: %d: %s',16,1,@error,@message,@lineNo);
			END CATCH 

END