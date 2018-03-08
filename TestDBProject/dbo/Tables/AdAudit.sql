CREATE TABLE [dbo].[AdAudit] (
    [AdAuditID]        INT      IDENTITY (1, 1) NOT NULL,
    [BeforeDetailsXML] XML      NOT NULL,
    [AfterDetailsXML]  XML      NOT NULL,
    [UserID]           INT      NOT NULL,
    [CreatedDT]        DATETIME NOT NULL,
    PRIMARY KEY CLUSTERED ([AdAuditID] ASC)
);

