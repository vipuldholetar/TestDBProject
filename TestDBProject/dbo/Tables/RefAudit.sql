CREATE TABLE [dbo].[RefAudit] (
    [RefAuditID]       INT          IDENTITY (1, 1) NOT NULL,
    [TableName]        VARCHAR (50) NOT NULL,
    [BeforeDetailsXML] XML          NOT NULL,
    [AfterDetailsXML]  XML          NOT NULL,
    [UserID]           INT          NOT NULL,
    [CreatedDT]        DATETIME     NOT NULL,
    PRIMARY KEY CLUSTERED ([RefAuditID] ASC),
    CONSTRAINT [FK_RefAudit_User] FOREIGN KEY ([UserID]) REFERENCES [dbo].[User] ([UserID])
);

