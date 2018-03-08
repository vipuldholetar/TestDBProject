CREATE TABLE [dbo].[AuditLogging] (
    [AuditLoggingID] INT          IDENTITY (1, 1) NOT NULL,
    [UserID]         INT          NULL,
    [idType]         VARCHAR (20) NOT NULL,
    [idValue]        INT          NOT NULL,
    [Action]         VARCHAR (50) NOT NULL,
    [MediaType]      INT          NOT NULL,
    [Update]         VARCHAR (50) NULL,
    [CreatedDT]      DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([AuditLoggingID] ASC),
    CONSTRAINT [FK_AuditLogging_MediaType] FOREIGN KEY ([MediaType]) REFERENCES [dbo].[OccurenceMediaType] ([OccurenceMediaTypeID]),
    CONSTRAINT [FK_AuditLogging_User] FOREIGN KEY ([UserID]) REFERENCES [dbo].[User] ([UserID])
);

