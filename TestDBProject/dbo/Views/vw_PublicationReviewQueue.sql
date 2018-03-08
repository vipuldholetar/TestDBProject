



-- =========================================================================
-- Author			: Murali 
-- Create date		: 17/06/2015
-- Description		: Get Publication details
-- Execution Process: SELECT * FROM [vw_PublicationReviewQueue] 
-- Updated By		: Arun Nair on 26/06/2015 for Language Addition
-- ===========================================================================

CREATE VIEW  [dbo].[vw_PublicationReviewQueue]
AS
SELECT  DBO.PUBISSUE.[PubIssueID] AS PUBISSUEID,
dbo.PUBISSUE.ISSUEDATE,
dbo.PUBISSUE.ISSUECOMPLETEINDICATOR AS ISSUECOMPLETE, 
dbo.PUBISSUE.ISSUEAUDITEDINDICATOR AS ISSUEAUDITED, 
dbo.PUBISSUE.STATUS AS ISSUESTATUS,
dbo.PUBISSUE.AUDITDTM, 
dbo.PUBISSUE.AUDITBY, 
dbo.PUBISSUE.QUERYCATEGORY, 
dbo.PUBISSUE.QUERYTEXT,
dbo.PUBISSUE.QUERYANSWER, 
dbo.PUBLICATION.DESCRIP AS PUBLICATION,
dbo.PUBLICATION.PRIORITY, 
dbo.PUBLICATION.COMMENTS AS PUBCOMMENTS,
dbo.SENDER.NAME AS SENDER,
dbo.SENDER.[SenderID] AS SENDERID,
dbo.[Market].[Descrip] AS MARKET, 
dbo.[Market].[MarketID] AS MARKETID,
dbo.PUBISSUE.ISQUERY AS ISQUERY,
PUBISSUE.MODIFIEDBY as MODIFIEDBY,
[Language].Description As LanguageName,
[Language].LanguageID
FROM  DBO.[Market] INNER JOIN DBO.PUBEDITION ON DBO.[Market].[MarketID] = DBO.PUBEDITION.[MarketID] 
INNER JOIN DBO.PUBISSUE ON DBO.PUBEDITION.[PubEditionID] = DBO.PUBISSUE.[PubEditionID] 
INNER JOIN DBO.PUBLICATION ON DBO.PUBEDITION.[PublicationID] = DBO.PUBLICATION.[PublicationID] 
INNER JOIN DBO.SENDER ON DBO.PUBISSUE.[SenderID] = DBO.SENDER.[SenderID]
INNER JOIN [Language] ON [Language].LanguageID=DBO.PUBEDITION.[LanguageID]
