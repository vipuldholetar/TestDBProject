CREATE TABLE [dbo].[RCSXmlDocs] (
    [RCSXmlDocsID]               INT      IDENTITY (1, 1) NOT NULL,
    [BiggestSeqForAirplayChange] BIGINT   NOT NULL,
    [RCSXmlDoc]                  XML      NOT NULL,
    [ParsedStatus]               TINYINT  NOT NULL,
    [XmlNodeCount]               INT      NULL,
    [CreatedDT]                  DATETIME NOT NULL,
    [CreatedByID]                INT      NOT NULL,
    [ModifiedDT]                 DATETIME NULL,
    [ModifiedByID]               INT      NULL,
    CONSTRAINT [PK_RCSXmlDocs_1] PRIMARY KEY CLUSTERED ([RCSXmlDocsID] ASC)
);

