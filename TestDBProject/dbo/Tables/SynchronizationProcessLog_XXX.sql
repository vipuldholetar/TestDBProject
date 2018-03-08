CREATE TABLE [dbo].[SynchronizationProcessLog_XXX] (
    [SynchronizationProcessLogID] INT          IDENTITY (1, 1) NOT NULL,
    [ProcessName]                 VARCHAR (50) NOT NULL,
    [ProcessDate]                 DATETIME     NOT NULL,
    [CreateDT]                    DATETIME     DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([SynchronizationProcessLogID] ASC)
);

