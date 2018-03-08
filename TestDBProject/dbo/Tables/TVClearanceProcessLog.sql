CREATE TABLE [dbo].[TVClearanceProcessLog] (
    [TVClearanceProcessLogID] INT      IDENTITY (1, 1) NOT NULL,
    [StationID]               INT      NOT NULL,
    [BroadcastDay]            DATETIME NULL,
    [OccurrenceCount]         INT      NULL,
    [BeginDT]                 DATETIME NOT NULL,
    [EndDT]                   DATETIME NULL,
    PRIMARY KEY CLUSTERED ([TVClearanceProcessLogID] ASC)
);

