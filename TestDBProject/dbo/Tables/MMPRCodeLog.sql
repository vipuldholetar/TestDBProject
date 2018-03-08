CREATE TABLE [dbo].[MMPRCodeLog] (
    [LogTimeStamp]              DATETIME     NULL,
    [LogDMLOperation]           CHAR (1)     NULL,
    [LoginUser]                 VARCHAR (32) NULL,
    [FakePatternCODE]           VARCHAR (50) NULL,
    [OriginalPRCode]            VARCHAR (50) NULL,
    [ApprovedMarket]            VARCHAR (50) NULL,
    [ApprovedForAllMarketsCODE] VARCHAR (50) NULL,
    [EffectiveStartDT]          VARCHAR (50) NULL,
    [EffectiveEndDT]            VARCHAR (50) NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

