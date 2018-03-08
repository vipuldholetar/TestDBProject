CREATE TABLE [dbo].[OccurrenceAudit] (
    [OccurrenceAuditID] INT          IDENTITY (1, 1) NOT NULL,
    [TableName]         VARCHAR (50) NOT NULL,
    [BeforeDetailsXML]  XML          NOT NULL,
    [AfterDetailsXML]   XML          NOT NULL,
    [UserID]            INT          NOT NULL,
    [CreatedDT]         DATETIME     NOT NULL,
    CONSTRAINT [PK__OccrncAu__F4A24BC27DCAFBEC] PRIMARY KEY CLUSTERED ([OccurrenceAuditID] ASC),
    CONSTRAINT [FK_OccrncAudit_User] FOREIGN KEY ([UserID]) REFERENCES [dbo].[User] ([UserID])
);

