CREATE TABLE [dbo].[TimezoneBALog] (
    [LogTimeStamp]     DATETIME      NULL,
    [LogDMLOperation]  CHAR (1)      NULL,
    [LoginUser]        VARCHAR (32)  NULL,
    [TVStationCode]    VARCHAR (255) NULL,
    [HoursOffset]      FLOAT (53)    NULL,
    [EffectiveStartDT] DATETIME      NULL,
    [EffectiveEndDT]   DATETIME      NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

