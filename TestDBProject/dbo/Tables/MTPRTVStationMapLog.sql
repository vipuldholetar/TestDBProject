CREATE TABLE [dbo].[MTPRTVStationMapLog] (
    [LogTimeStamp]     DATETIME      NULL,
    [LogDMLOperation]  CHAR (1)      NULL,
    [LoginUser]        VARCHAR (32)  NULL,
    [PRStationCODE]    VARCHAR (200) NULL,
    [MTStationID]      INT           NULL,
    [EthnicID]         INT           NULL,
    [EffectiveStartDT] DATETIME      NULL,
    [EffectiveEndDT]   DATETIME      NULL,
    [CreatedDT]        DATETIME      NULL,
    [CreatedByID]      INT           NULL,
    [ModifiedDT]       DATETIME      NULL,
    [ModifiedByID]     INT           NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

