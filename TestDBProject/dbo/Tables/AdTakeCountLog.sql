CREATE TABLE [dbo].[AdTakeCountLog] (
    [LogTimeStamp]        DATETIME     NULL,
    [LogDMLOperation]     CHAR (1)     NULL,
    [LoginUser]           VARCHAR (32) NULL,
    [AdTakeCountID]       INT          NULL,
    [AdvertiserID]        INT          NULL,
    [OldVal_AdvertiserID] INT          NULL,
    [MediaStream]         INT          NULL,
    [OldVal_MediaStream]  INT          NULL,
    [LanguageID]          INT          NULL,
    [OldVal_LanguageID]   INT          NULL,
    [MonthYear]           VARCHAR (50) NULL,
    [OldVal_MonthYear]    VARCHAR (50) NULL,
    [MaxTakeCount]        INT          NULL,
    [OldVal_MaxTakeCount] INT          NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

