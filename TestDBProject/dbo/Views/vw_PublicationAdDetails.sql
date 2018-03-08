












-- ==================================================================
-- Author			: Arun Nair 
-- Create date		: 13/06/2015
-- Description		: Select Ad Details in DPF For Publication
-- Execution Process: [dbo].[vw_PublicationAdDetails]
-- Updated By		:	
-- ==================================================================
CREATE VIEW [dbo].[vw_PublicationAdDetails]
AS

	SELECT distinct Ad.[AdID] as AdID,Ad.[OriginalAdID],LeadAvHeadline AS [LeadAudioHeadline],LeadText AS [TitleLeadText] ,AdVisual AS [Visual],
	Ad.[Description],[Advertiser].Descrip AS Advertiser,[Language].LanguageID AS [Language],TaglineID AS [Tagline],[CommonAdDT],
	InternalNotes AS [InternalLookupNotes],NoTakeAdReason AS [NoTakeReason],[Pattern].MediaStream AS MediaStreamID, AdLength AS [Length],
	[Creative].PrimaryQuality AS [CreativeAssetQuality],[TradeClass].Descrip AS Tradeclass,'' AS [CoreSupplemental],'' AS [DistributionType],RecutDetail AS [RevisionDetail],
	PubIssue.IssueDate,AD.[FirstRunMarketID] AS [FirstRunDMA],SessionDate AS SessionDate,[Advertiser].AdvertiserID  As AdvertiserID,[Language].LanguageID AS LanguageID
	 FROM  AD 
	 INNER JOIN [Advertiser] ON Ad.[AdvertiserID]=[Advertiser].AdvertiserID
	 INNER JOIN [Pattern] On AD.[AdID]=[Pattern].[AdID]
	 INNER JOIN [OccurrenceDetailPUB] ON [OccurrenceDetailPUB].[AdID] = AD.[AdID]
	 LEFT JOIN [TradeClass] ON [Advertiser].AdvertiserID=[TradeClass].[TradeClassID]
	 INNER JOIN [Language] ON [Language].LanguageID =Ad.[LanguageID]
	 Left Join [Creative] on [Pattern].[CreativeID]=[Creative].PK_Id 
	 LEFT JOIN PubIssue ON [OccurrenceDetailPUB].[PubIssueID]=PubIssue.[PubIssueID]
	 --Left JOIN Envelope ON PubIssue.FK_EnvelopeID =Envelope.PK_EnvelopeId	 