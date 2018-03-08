



-- ============================================================================
-- Author			: Arun Nair
-- Create date		: 
-- Description		: Get Pubissue Data
-- Execution		: Select * from [dbo].[vw_PublicationWorkQueueIssueData]
-- Updated By		: Karunakar on 20th Jan 2016,Adding Source OccurrenceID and Pub section name
--=============================================================================
CREATE VIEW [dbo].[vw_PublicationWorkQueueIssueData]
AS
SELECT  PubIssue.[PubIssueID] AS IssueId,
Publication.Descrip As Publication,
PubIssue.IssueDate,
Publication.Priority,
Sender.Name As Sender, 
[Market].[Descrip] As Market,
PubIssue.IssueCompleteIndicator As IssueComplete,
PubIssue.IssueAuditedIndicator As IssueAudited,
PubIssue.Status As PubIssueStatus,
Publication.Comments,
PubIssue.CreateDTM,
PubEdition.[LanguageID] As LanguageID,
Publication.[SourceID] As SourceId,
IsQuery,
[Language].Description As [Language],
[Market].[MarketID] As MarketId,
PubIssue.CpnOccurrenceID as SourceOccurrenceID,
PubSection.PubSectionName
FROM          PubIssue 
INNER JOIN    PubEdition ON PubIssue.[PubEditionID] = PubEdition.[PubEditionID] 
INNER JOIN    Publication ON PubEdition.[PublicationID] = Publication.[PublicationID] 
INNER JOIN    Sender ON PubIssue.[SenderID] = Sender.[SenderID] 
INNER JOIN    [Market] ON PubEdition.[MarketID] = [Market].[MarketID]
INNER JOIN    [Language] on PubEdition.[LanguageID]=[Language].LanguageID
Left Join	  PubSection ON PubIssue.FK_PubSection=PubSection.[PubSectionID]
