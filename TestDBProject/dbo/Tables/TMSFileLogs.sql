CREATE TABLE [dbo].[TMSFileLogs] (
    [TMSFileLogsID]          INT          IDENTITY (1, 1) NOT NULL,
    [FileName]               VARCHAR (50) NOT NULL,
    [FileRecordCount]        INT          NOT NULL,
    [AirDT]                  DATETIME     NOT NULL,
    [RawDataCount]           INT          NULL,
    [TranslationImportCount] INT          NOT NULL,
    [FinalCount]             INT          NOT NULL,
    [ProcessedDT]            DATETIME     NOT NULL,
    CONSTRAINT [PK_TMSFileLogs] PRIMARY KEY CLUSTERED ([TMSFileLogsID] ASC)
);

