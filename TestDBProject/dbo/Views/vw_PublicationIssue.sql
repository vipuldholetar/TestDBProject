








-- ======================================================================
-- Author		: Arun Nair 
-- Create date	: 06/05/2015
-- Execution	: [dbo].[vw_PublicationIssue]
-- Description	: Get Occurence Data for Publication Issue 
-- Updated By	:   
--========================================================================
CREATE VIEW [dbo].[vw_PublicationIssue]
AS
SELECT distinct 
[dbo].[PubIssue].[PubIssueID] As [IssueID],
Sender.[SenderID] As [SenderID],
Sender.Name as [SenderName],
[dbo].[Publication].Descrip As [PublicationName],
[dbo].[Publication].Comments,
[dbo].[PubIssue].IssueDate,
[dbo].[PubIssue].[EnvelopeID] As [EnvelopeID],
[dbo].[PubIssue].TrackingNumber,
[dbo].[PubIssue].PrintedWeight,
[dbo].[PubIssue].ActualWeight,
[dbo].[PubIssue].[PackageTypeID],
[dbo].[PubIssue].NoTakeReason,
[dbo].[PubIssue].[CpnOccurrenceID],
[dbo].[PubIssue].[ReceiveOn],
[dbo].[PubIssue].[ReceiveBy],
[dbo].[PubIssue].[IssueCompleteIndicator],
[dbo].[PubIssue].[IssueAuditedIndicator],
[dbo].[PubIssue].[Status],
[dbo].[PubIssue].[IsQuery],
[dbo].[PubIssue].[QueryCategory],
[dbo].[PubIssue].[QueryText],
[dbo].[PubIssue].[QryRaisedBy],
[dbo].[PubIssue].[QryRaisedOn],
[dbo].[PubIssue].[QueryAnswer],
[dbo].[PubIssue].[QryAnsweredBy],
[dbo].[PubIssue].[QryAnsweredOn],
[dbo].[PubIssue].[AuditBy],
[dbo].[PubIssue].[AuditDTM],
[dbo].[PubIssue].[CreateDTM],
[dbo].[PubIssue].[CreateBy],
[dbo].[PubIssue].[ModifiedDTM],
[dbo].[PubIssue].[ModifiedBy],
[dbo].[PubEdition].[PubEditionID] AS [EditionID],
[dbo].[MediaType].Descrip AS [MediaType],
[dbo].[Language].[Description] As [Language],
Convert(VARCHAR(50),[dbo].[user].fname+' '+[dbo].[user].lname) +'/'+ Convert(VARCHAR(10),
[dbo].[PubIssue].[CreateDTM],101) AS [CreateBy/On],
[dbo].[Publication].[Priority] As PublicationPriority,
[dbo].[Market].[MarketID] AS MarketID,
[dbo].[PubEdition].EditionName,
[dbo].[Market].[Descrip] AS MarketName
FROM [dbo].[PubIssue] 
INNER JOIN [dbo].[Sender] ON [dbo].[Sender].[SenderID]=[dbo].[PubIssue].[SenderID] 
INNER JOIN [dbo].[PubEdition] ON [dbo].[PubEdition].[PubEditionID]=[dbo].[PubIssue].[PubEditionID]
INNER JOIN [dbo].[Publication] ON [dbo].[Publication].[PublicationID]=[dbo].[PubEdition].[PublicationID]
INNER JOIN [dbo].[Market] ON [dbo].[PubEdition].[MarketID]=[dbo].[Market].[MarketID]
LEFT JOIN [dbo].[OccurrenceDetailPUB] ON [dbo].[OccurrenceDetailPUB].[PubIssueID]=[dbo].[PubIssue].[PubIssueID] 
LEFT JOIN [dbo].[MediaType] ON  [dbo].[MediaType].[MediaTypeID]=[dbo].[OccurrenceDetailPUB].[MediaTypeID]
INNER JOIN [dbo].[Language] ON  [dbo].[Language].LanguageId=[dbo].[PubEdition].[LanguageID]
INNER JOIN dbo.[user] on [user].userid=[PubIssue].createby