-- ==========================================================================
-- Author			:	Arun Nair 
-- Create date		:	20/05/2015
-- Description		:	Select Ad Details in DPF For Circular
-- Execution Process:	sp_GetCircularAdDetails 31793
-- Updated By		:	Karunakar on 7th Sep 2015
-- ==========================================================================

CREATE PROCEDURE [dbo].[sp_GetCircularAdDetails]
(
@AdID AS INT
)
AS
BEGIN
SELECT  Distinct Ad.[AdID] as AdID, [LeadAvHeadline] AS LeadAudioHeadline,LeadText as TitleLeadText,[AdVisual] as Visual,[Description],
[Advertiser].Descrip as Advertiser,
Ad.[LanguageID] as [Language],TaglineId as [Tagline],[CommonAdDT],[InternalNotes] as [InternalLookupNotes],[NoTakeAdReason],
[Pattern].MediaStream as MediaStreamId,[AdLength] as [Length],
[Creative].PrimaryQuality AS [CreativeAssetQuality],[TradeClass].Descrip as TradeClass,''as [CoreSupplemental],'' as [DistributionType],
Ad.RecutDetail as [RevisionDetail],[FirstRunDate],[LastRunDate], [FirstRunMarketID] as [FirstRunDMA],SessionDate,[Advertiser].Advertiserid as AdvertiserID,Ad.[LanguageID] as LanguageID ,
[Pattern].[SalesStartDT],[Pattern].[SalesEndDT],BreakDT
FROM Ad 
INNER JOIN [OccurrenceDetailCIR] ON [OccurrenceDetailCIR].[OccurrenceDetailCIRID]=Ad.[PrimaryOccurrenceID]
INNER JOIN  [Pattern] ON Ad.[AdID] = [Pattern].[AdID] AND [OccurrenceDetailCIR].[PatternID]=[Pattern].[PatternID]
INNER JOIN   [Creative] ON [Pattern].[CreativeID]=[Creative].PK_Id
INNER JOIN  [Advertiser] ON [Advertiser].advertiserid=Ad.[AdvertiserID] 
LEFT OUTER join   [TradeClass] ON [Advertiser].[TradeClassID]=[TradeClass].[TradeClassID]
                WHERE Ad.[AdID]=@AdiD and [Creative].PrimaryIndicator IS NOT NULL
END