




-- ====================================================================================================
-- Author			: Arun Nair 
-- Create date		: 20/05/2015
-- Description		: This view is to retrieve Occurrence Details For Display in DPF For Circular
-- Execution		: [dbo].[vw_CircularOccurrenceDetails]
-- Updated By		: Karunakar on 11th August 2015
-- =====================================================================================================
CREATE VIEW [dbo].[vw_CircularOccurrenceDetails]
AS
SELECT [OccurrenceDetailCIR].[OccurrenceDetailCIRID] AS OccurrenceID,[Advertiser].Descrip AS [Advertiser],[TradeClass].Descrip As [TradeClass],
Ad.[CommonAdDT],[Event].Descrip AS [Event],[Theme].Descrip AS [Theme],
[Pattern].[SalesStartDT],[Pattern].[SalesEndDT],[Pattern].[FlashInd] AS Flash,[Pattern].NationalIndicator AS [National],
MediaType.Descrip AS MediaType,[Market].[Descrip] AS [Market],[OccurrenceDetailCIR].Priority AS [Priority],[OccurrenceDetailCIR].Color,
[OccurrenceDetailCIR].PageCount AS [PageCount],Publication.Descrip As Publication,PubEdition.EditionName AS [Edition],
[OccurrenceDetailCIR].DistributionDate AS DistributionDate,[OccurrenceDetailCIR].PubPageNumber,
[OccurrenceDetailCIR].SizingMethod,[Pattern].Mediastream As [MediaStreamId],MediaType.[MediaTypeID] As MediaTypeID,
Source.Descrip AS Source,SubSource.SubSourceName,[Language].Description AS [Ethnicity],
[Advertiser].AdvertiserComments,'' AS MediaTypeComments,[OccurrenceDetailCIR].InternalRefenceNotes AS InternalReferenceNotes,
[OccurrenceDetailCIR].FlyerID,[Event].[EventID] As EventID,[Theme].[ThemeID] AS ThemeID,Publication.[PublicationID] AS PublicationID,
PubEdition.[PublicationID] AS PubEditionID,SubSource.[SubSourceID] AS SubSourceID,Source.[SourceID] AS SourceID,[Pattern].[PatternID] AS PatternMasterID,
[Envelope].[EnvelopeID] AS EnvelopeID,[Market].[MarketID] AS MarketID,[TradeClass].[TradeClassID],AdDate
FROM [dbo].[OccurrenceDetailCIR]
LEFT JOIN [Advertiser] ON [Advertiser].AdvertiserID=[OccurrenceDetailCIR].[AdvertiserID]
LEFT JOIN [TradeClass] ON [Advertiser].[TradeClassID]=[TradeClass].[TradeClassID]
LEFT JOIN Ad ON [OccurrenceDetailCIR].[AdID] = AD.[AdID]
INNER JOIN [Pattern] ON [OccurrenceDetailCIR].[PatternID]=[Pattern].[PatternID]
LEFT JOIN [Event] ON [Event].[EventID]=[Pattern].[EventID]
LEFT JOIN [Theme] ON [Theme].[ThemeID]=[Pattern].[ThemeID]
INNER JOIN MediaType ON [OccurrenceDetailCIR].[MediaTypeID]=MediaType.[MediaTypeID]
LEFt JOIN [Market] ON [OccurrenceDetailCIR].[MarketID]=[Market].[MarketID]
INNER JOIN PubEdition ON [OccurrenceDetailCIR].[PubEditionID]=PubEdition.[PubEditionID]
LEFT JOIN PUBLICATION ON PubEdition.[PublicationID]=Publication.[PublicationID] 
INNER JOIN [Envelope] ON [OccurrenceDetailCIR].[EnvelopeID] =[Envelope].[EnvelopeID]
LEFT  JOIN  SubSource ON   [OccurrenceDetailCIR].[SubSourceID]=SubSource.[SubSourceID]
LEFT  JOIN Source ON  Source.[SourceID]=Subsource.[SourceID]
LEFT  JOIN [Language] ON [Language].LanguageID=PubEdition.[LanguageID]
--LEFT  JOIN Expectation ON OccurrenceDetailsCIR.FK_MarketId=Expectation.MktId  