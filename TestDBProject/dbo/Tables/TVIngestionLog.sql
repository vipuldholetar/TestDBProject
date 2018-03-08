CREATE TABLE [dbo].[TVIngestionLog] (
    [TVIngestionLogID]       BIGINT        IDENTITY (1, 1) NOT NULL,
    [SrcFileName]            VARCHAR (200) NOT NULL,
    [OccurrencesCountInFile] INT           NOT NULL,
    [OccurrencesInserted]    INT           NULL,
    [OccurrencesUpdated]     INT           NULL,
    [OccurrencesDeleted]     INT           NULL,
    [FileSkippedFor0024]     INT           NULL,
    [LogEntryDT]             DATETIME      NULL,
    CONSTRAINT [PK_TVIngestionLog] PRIMARY KEY CLUSTERED ([TVIngestionLogID] ASC)
);

