




-- ============================================================================================
-- Author			:	Arun Nair on 20/05/2015
-- Description		:	This view is to retrieve Ad Details For Display in DPF For Circular
-- Updated By		:	Karunakar on 11th August 2015
-- ==============================================================================================

CREATE VIEW [dbo].[vw_CircularAdDetails]
AS

	SELECT distinct Ad.[AdID] As AdID,Ad.[OriginalAdID],LeadAvHeadline AS [LeadAudioHeadline],LeadText AS [TitleLeadText] ,ADVisual AS [Visual],
	Ad.[Description],[Advertiser].Descrip AS Advertiser,[Language].LanguageID AS [Language],TaglineID AS [Tagline],[CommonAdDT],
	InternalNotes AS [InternalLookupNotes],NoTakeAdReason AS [NoTakeReason],[Pattern].MediaStream AS MediaStreamID, AdLength AS [Length],
	[Creative].PrimaryQuality AS [CreativeAssetQuality],[TradeClass].Descrip AS Tradeclass,'' AS [CoreSupplemental],'' AS [DistributionType],RecutDetail AS [RevisionDetail],
	[OccurrenceDetailCIR].DistributionDate AS [FirstRunDate],[OccurrenceDetailCIR].DistributionDate AS [LastRunDate],
	 [FirstRunMarketID] AS [FirstRunDMA],Ad.SessionDate AS SessionDate,[Advertiser].AdvertiserID  As AdvertiserID,[Language].LanguageID AS LanguageID
	 FROM  AD 
	 inner Join [Advertiser] ON Ad.[AdvertiserID]=[Advertiser].AdvertiserID 
	 left Join [TradeClass] ON [Advertiser].AdvertiserID=[TradeClass].[TradeClassID]
	 inner Join [Language] ON [Language].LanguageID =Ad.[LanguageID]
	 left Join [Pattern] On AD.[AdID]=[Pattern].[AdID]
	 Left Join [OccurrenceDetailCIR] ON [OccurrenceDetailCIR].[AdID] = AD.[AdID]
	 inner Join [Envelope] ON [OccurrenceDetailCIR].[EnvelopeID] =[Envelope].[EnvelopeID]
	 Left Join [Creative] On [Pattern].[CreativeID]=[Creative].PK_ID 
	 and AD.[AdID]=[Creative].[AdId]