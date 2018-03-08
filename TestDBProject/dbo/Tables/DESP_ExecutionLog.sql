CREATE TABLE [dbo].[DESP_ExecutionLog] (
    [StoredProcedureId] INT            NOT NULL,
    [RunDt]             DATETIME       NOT NULL,
    [UserName]          VARCHAR (100)  NOT NULL,
    [Parameters]        VARCHAR (1000) NULL
);

