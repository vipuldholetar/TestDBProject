CREATE TABLE [dbo].[PatternAudit] (
    [PatternAuditID]   INT      IDENTITY (1, 1) NOT NULL,
    [BeforeDetailsXML] XML      NOT NULL,
    [AfterDetailsXML]  XML      NOT NULL,
    [UserID]           INT      NOT NULL,
    [CreatedDT]        DATETIME NOT NULL,
    PRIMARY KEY CLUSTERED ([PatternAuditID] ASC)
);

