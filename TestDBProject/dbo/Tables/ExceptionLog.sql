CREATE TABLE [dbo].[ExceptionLog] (
    [LogID]          INT            IDENTITY (1, 1) NOT NULL,
    [ProcessManager] VARCHAR (50)   NOT NULL,
    [ProcessEngine]  VARBINARY (50) NOT NULL,
    [LogEntry]       XML            NOT NULL
);

