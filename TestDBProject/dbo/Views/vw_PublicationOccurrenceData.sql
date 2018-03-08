



-- =======================================================================================
-- Author		: Karunakar
-- Create date	: 06/05/2015
-- Execution	:
-- Description	: Get the Publication Work Queue Data    
-- Updated By	: Murali on 11/06/2015
--				  Arun Nair on 12/31/2015 - Added New Cols for MultiEdition,PubType
--=====================================================================================

CREATE VIEW [dbo].[vw_PublicationOccurrenceData]
AS
SELECT  distinct [OccurrenceDetailPUB].[OccurrenceDetailPUBID],
[OccurrenceDetailPUB].[PubIssueID] As PubIssueId,
[Advertiser].Descrip As Advertiser,
[Advertiser].AdvertiserID,
(select [Status] from OccurrenceStatus where OccurrenceStatusID = [OccurrenceDetailPUB].OccurrenceStatusID) as OccurrenceStatus,
(select [Status] from MapStatus where MapStatusID = [OccurrenceDetailPUB].MapStatusID) as MapStatus,
(select [Status] from IndexStatus where IndexStatusID = [OccurrenceDetailPUB].IndexStatusID) as IndexStatus,
(select [Status] from ScanStatus where ScanStatusID = [OccurrenceDetailPUB].ScanStatusID) as ScanStatus,
(select [Status] from QCStatus where QCStatusID = [OccurrenceDetailPUB].QCStatusID) as QCStatus,
(select [Status] from RouteStatus where RouteStatusID = [OccurrenceDetailPUB].RouteStatusID) as RouteStatus,
[Pattern].Priority,
MediaType.Descrip As MediaType,
CreativeDetailPub.[PageTypeID],
[OccurrenceDetailPUB].PubPageNumber,
[OccurrenceDetailPUB].[AdID] As AdId,
[OccurrenceDetailPUB].[Query],
[OccurrenceDetailPUB].[MediaTypeID], 
[Pattern].[EventID], 
[Pattern].[ThemeID],  
[Pattern].[SalesStartDT],
[Pattern].[SalesEndDT],
[Pattern].MediaStream, [Pattern].[FlashInd], 
[Pattern].NationalIndicator, 
[OccurrenceDetailPUB].Color,
[OccurrenceDetailPUB].PageCount,
[OccurrenceDetailPUB].SizingMethod,
[OccurrenceDetailPUB].[SubSourceID],
[OccurrenceDetailPUB].[MarketID],
[OccurrenceDetailPUB].Priority As OccurrencePriority,
[OccurrenceDetailPUB].[AdDT],
Publication.Descrip As Publication,
PubEdition.EditionName,
PubEdition.[PubEditionID],
Publication.[PublicationID],
Publication.[Priority] as PublicationPriority,
Pubissue.IssueDate,[TradeClass].Descrip As TradeClass,[Language].Description As LanguageName,[Language].LanguageID,
[OccurrenceDetailPUB].InternalRefenceNotes,[Source].[SourceID],[Source].[Descrip] As SourceDescription,
[OccurrenceDetailPUB].[SizeID],[OccurrenceDetailPUB].[PubSectionID],[OccurrenceDetailPUB].Size,
[Configuration].valuetitle AS PubType
FROM  [OccurrenceDetailPUB] 
INNER JOIN AD ON [OccurrenceDetailPUB].[AdID] = AD.[AdID] 
INNER JOIN [Advertiser] ON AD.[AdvertiserID] = [Advertiser].AdvertiserID 
INNER JOIN [Pattern] ON [OccurrenceDetailPUB].[PatternID] = [Pattern].[PatternID] AND AD.[AdID] = [Pattern].[AdID]  				    
LEFT JOIN MediaType ON [OccurrenceDetailPUB].[MediaTypeID] = MediaType.[MediaTypeID]
INNER join PubIssue on [OccurrenceDetailPUB].[PubIssueID]=PubIssue.[PubIssueID]
LEFT join PubEdition on PubIssue.[PubEditionID]=PubEdition.[PubEditionID]
LEFT join Publication on PubEdition.[PublicationID]=Publication.[PublicationID]
LEFT JOIN [Creative] on [Pattern].[CreativeID]=[Creative].PK_Id
LEFT JOIN CreativeDetailPub On [Creative].PK_Id=CreativeDetailPUB.CreativeMasterID and creativedetailpub.pagenumber=1
LEFT Join [TradeClass] on [Advertiser].[TradeClassID]=[TradeClass].[TradeClassID]
LEFT Join [Language] on AD.[LanguageID]=[Language].LanguageID
LEFT Join SubSource on [OccurrenceDetailPUB].[SubSourceID]=SubSource.[SubSourceID]
LEFT Join [Source]  on SubSource.[SourceID]=[Source].[SourceID]
INNER JOIN dbo.[Configuration] ON Publication.PubType =[Configuration].Configurationid