





-- =============================================================================================
-- Author		: Arun Nair 
-- Create date	: 21 April 2015
-- Description	: Get Occurence Data for circular
-- Exceution	: Select * from [dbo].[vw_CircularOccurrences]
-- Updated By	: Karunakar on 11th August 2015,Changing Patternmaster Fileds   
--				  Arun Nair On 10/05/2015 - Added EnvelopeId
--===============================================================================================

CREATE VIEW [dbo].[vw_CircularOccurrences]
AS
SELECT        Sender.Name as sendername , [OccurrenceDetailCIR].[OccurrenceDetailCIRID], MediaType.Descrip AS MediaTypeDescription, [Market].[Descrip] as MarketDescription, Publication.Descrip AS Publication, 
                         PubEdition.EditionName, [Language].Description AS Language, [OccurrenceDetailCIR].DistributionDate, [OccurrenceDetailCIR].AdDate, 
                         [Advertiser].Descrip AS Advertiser, [TradeClass].Descrip AS TradeClass, [OccurrenceDetailCIR].Priority AS OccurrenceCIRPriority, [Advertiser].AdvertiserComments AS COMMENTS, 
                         [OccurrenceDetailCIR].[AdvertiserID], [OccurrenceDetailCIR].[MediaTypeID], [OccurrenceDetailCIR].[MarketID], 
                         [OccurrenceDetailCIR].[PubEditionID], [OccurrenceDetailCIR].[LanguageID], [OccurrenceDetailCIR].[EnvelopeID] as OccurrenceDetailCIREnvelopeID, 
                         [OccurrenceDetailCIR].InternalRefenceNotes, [OccurrenceDetailCIR].[PatternID], 
                         [OccurrenceDetailCIR].[AdID], [OccurrenceDetailCIR].PageCount, [Pattern].[FlashInd], [Pattern].NationalIndicator,[OccurrenceDetailCIR].[CreatedByID],[user].FName+' '+[user].lname as Username,
						 (select [Status] from OccurrenceStatus where OccurrenceStatusID = [OccurrenceDetailCIR].OccurrenceStatusID) as OccurrenceStatus,
						 (select [Status] from MapStatus where MapStatusID = [OccurrenceDetailCIR].MapStatusID) as MapStatus,
						 (select [Status] from IndexStatus where IndexStatusID = [OccurrenceDetailCIR].IndexStatusID) as IndexStatus,
						 (select [Status] from ScanStatus where ScanStatusID = [OccurrenceDetailCIR].ScanStatusID) as ScanStatus,
						 (select [Status] from QCStatus where QCStatusID = [OccurrenceDetailCIR].QCStatusID) as QCStatus,
						 (select [Status] from RouteStatus where RouteStatusID = [OccurrenceDetailCIR].RouteStatusID) as RouteStatus,
						 [Pattern].Priority AS PatternMasterPriority,[OccurrenceDetailCIR].[Query],[OccurrenceDetailCIR].QueryCategory,
						 [OccurrenceDetailCIR].QueryText,[OccurrenceDetailCIR].QueryAnswer,[OccurrenceDetailCIR].QryRaisedBy,[OccurrenceDetailCIR].[QryRaisedDT],[OccurrenceDetailCIR].Color,[OccurrenceDetailCIR].SizingMethod,
						 Publication.[PublicationID],[OccurrenceDetailCIR].[CreatedDT],
						 [Pattern].CouponIndicator,[Pattern].[SalesStartDT],[Pattern].[SalesEndDT],[Pattern].[EventID],[Pattern].[ThemeID],[Event].Descrip as Event,
						 [Theme].descrip as theme,[OccurrenceDetailCIR].[ModifiedByID],[OccurrenceDetailCIR].AuditBy,[OccurrenceDetailCIR].AuditDTM,
						 [Envelope].[EnvelopeID] As EnvelopeId
FROM            [Envelope] INNER JOIN
                         [OccurrenceDetailCIR] ON [Envelope].[EnvelopeID] = [OccurrenceDetailCIR].[EnvelopeID] INNER JOIN
                         [Market] ON [OccurrenceDetailCIR].[MarketID] = [Market].[MarketID] INNER JOIN
                         PubEdition ON [OccurrenceDetailCIR].[PubEditionID] = PubEdition.[PubEditionID] INNER JOIN
                         Publication ON PubEdition.[PublicationID] = Publication.[PublicationID] INNER JOIN
                         [Advertiser] ON [OccurrenceDetailCIR].[AdvertiserID] = [Advertiser].AdvertiserID INNER JOIN
                         [Pattern] ON [OccurrenceDetailCIR].[PatternID] = [Pattern].[PatternID] INNER JOIN
                         Sender ON [Envelope].[SenderID] = Sender.[SenderID] INNER JOIN
                         [Language] ON [OccurrenceDetailCIR].[LanguageID] = [Language].LanguageID left outer JOIN
                         [TradeClass] ON [Advertiser].[TradeClassID] = [TradeClass].[TradeClassID] INNER JOIN
                         MediaType ON [OccurrenceDetailCIR].[MediaTypeID] = MediaType.[MediaTypeID]
						 inner join [USER] on [user].userid=[OccurrenceDetailCIR].[CreatedByID] 
						 left outer join [Event] on [Pattern].[EventID]=[Event].[EventID]
						 left outer join [Theme] on [Pattern].[ThemeID]=[Theme].[ThemeID]