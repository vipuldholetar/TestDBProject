CREATE TABLE [dbo].[SynchronizationProcessLog] (
    [SynchronizationProcessLogID] INT          IDENTITY (1, 1) NOT NULL,
    [ProcessName]                 VARCHAR (50) NOT NULL,
    [ProcessDate]                 DATETIME     NOT NULL,
    [CreateDT]                    DATETIME     DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([SynchronizationProcessLogID] ASC)
);

