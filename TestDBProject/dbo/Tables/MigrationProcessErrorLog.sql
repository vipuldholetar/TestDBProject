CREATE TABLE [dbo].[MigrationProcessErrorLog] (
    [MigrationProcessErrorLogID] INT           IDENTITY (1, 1) NOT NULL,
    [MigrationProcessLogID]      INT           NOT NULL,
    [CTLegacyID]                 INT           NOT NULL,
    [ErrorMessage]               VARCHAR (MAX) NOT NULL,
    [ErrorColumn]                VARCHAR (MAX) NULL,
    [CreatedDT]                  DATETIME      DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([MigrationProcessErrorLogID] ASC),
    CONSTRAINT [FK_MigrationProcessErrorLog_ToMigrationProcessLog] FOREIGN KEY ([MigrationProcessLogID]) REFERENCES [dbo].[MigrationProcessLog] ([MigrationProcessLogID])
);

