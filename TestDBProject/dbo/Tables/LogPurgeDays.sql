CREATE TABLE [dbo].[LogPurgeDays] (
    [logtablename] VARCHAR (128) NOT NULL,
    [daystopurge]  INT           NOT NULL,
    [lastrundt]    DATETIME      NULL,
    [runstartdt]   DATETIME      NULL
);

