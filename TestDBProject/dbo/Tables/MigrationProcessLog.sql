CREATE TABLE [dbo].[MigrationProcessLog] (
    [MigrationProcessLogID] INT          IDENTITY (1, 1) NOT NULL,
    [ProcessName]           VARCHAR (50) NOT NULL,
    [DateRangeStart]        DATE         NULL,
    [DateRangeEnd]          DATE         NULL,
    [RecordsInserted]       INT          NULL,
    [ElapsedTimeSecs]       INT          NULL,
    [LastProcessedDT]       DATE         NULL,
    [CreatedDT]             DATETIME     NOT NULL,
    PRIMARY KEY CLUSTERED ([MigrationProcessLogID] ASC)
);

