CREATE TABLE [dbo].[TakeCountsCurrentAdvLog] (
    [LogTimeStamp]    DATETIME      NULL,
    [LogDMLOperation] CHAR (1)      NULL,
    [LoginUser]       VARCHAR (32)  NULL,
    [Advertiser]      VARCHAR (100) NULL,
    [MediaStream]     VARCHAR (100) NULL,
    [Ethnicity]       VARCHAR (50)  NULL,
    [Limit]           BIGINT        NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

