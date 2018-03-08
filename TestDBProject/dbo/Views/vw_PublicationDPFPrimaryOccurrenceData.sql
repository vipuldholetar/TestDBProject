



-- ==========================================================================
-- Author			:	Karunakar  
-- Create date		:	13/06/2015
-- Execution		:	[dbo].[vw_PublicationDPFPrimaryOccurrenceData]
-- Description		:	Getting Primary Occcurrence Data for Publication
-- Updated By		:
-- ==========================================================================
CREATE VIEW [dbo].[vw_PublicationDPFPrimaryOccurrenceData]
As 

SELECT        [OccurrenceDetailPUB].[OccurrenceDetailPUBID],[OccurrenceDetailPUB].[MediaTypeID], [Pattern].[EventID], [Pattern].[ThemeID],  
[Pattern].[SalesStartDT], [Pattern].[SalesEndDT], [Pattern].[FlashInd], [Pattern].NationalIndicator, 
[OccurrenceDetailPUB].Color, [OccurrenceDetailPUB].PageCount, [OccurrenceDetailPUB].PubPageNumber, [OccurrenceDetailPUB].SizingMethod, 
[OccurrenceDetailPUB].[SubSourceID],[OccurrenceDetailPUB].[MarketID],[OccurrenceDetailPUB].Priority,[OccurrenceDetailPUB].[AdDT]
FROM            [OccurrenceDetailPUB] INNER JOIN
 [Pattern] ON [OccurrenceDetailPUB].[PatternID] = [Pattern].[PatternID]
