CREATE TABLE [dbo].[SynchronizationProcessControl_XXX] (
    [SynchronizationProcessControlID] INT           IDENTITY (1, 1) NOT NULL,
    [MTTable]                         VARCHAR (100) NULL,
    [MTDB]                            VARCHAR (100) NULL,
    [MTLogDB]                         VARCHAR (100) NULL,
    [OraTable]                        VARCHAR (100) NULL,
    [Media]                           VARCHAR (100) NULL,
    [TableType]                       VARCHAR (100) NULL,
    [Priority]                        INT           NULL,
    [ProcessName]                     VARCHAR (30)  NULL
);

