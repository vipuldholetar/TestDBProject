CREATE TABLE [dbo].[MM_PR_CODES_BALog] (
    [LogTimeStamp]              DATETIME       NULL,
    [LogDMLOperation]           CHAR (1)       NULL,
    [LoginUser]                 VARCHAR (32)   NULL,
    [FakePatternCODE]           NVARCHAR (255) NULL,
    [OriginalPRCODE]            NVARCHAR (255) NULL,
    [ApprovedMarket]            NVARCHAR (255) NULL,
    [ApprovedForAllMarketsCODE] NVARCHAR (255) NULL,
    [EffectiveStartDT]          DATETIME       NULL,
    [EffectiveEndDT]            DATETIME       NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

