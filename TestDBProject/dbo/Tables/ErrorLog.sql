CREATE TABLE [dbo].[ErrorLog] (
    [LogID]             INT           IDENTITY (1, 1) NOT NULL,
    [EventType]         VARCHAR (50)  NOT NULL,
    [ProcessManager]    VARCHAR (50)  NOT NULL,
    [ProcessEngine]     VARCHAR (50)  NOT NULL,
    [JobID]             VARCHAR (10)  NOT NULL,
    [JobPackageID]      VARCHAR (10)  NOT NULL,
    [JobStepID]         VARCHAR (10)  NOT NULL,
    [ServiceEventType]  VARCHAR (50)  NOT NULL,
    [LogDisplayMessage] VARCHAR (50)  NOT NULL,
    [LogDetails]        VARCHAR (MAX) NOT NULL,
    [TimeStamp]         DATETIME      NOT NULL
);

