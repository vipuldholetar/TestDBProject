CREATE TABLE [dbo].[TakeCountsIndustryLog] (
    [LogTimeStamp]    DATETIME      NULL,
    [LogDMLOperation] CHAR (1)      NULL,
    [LoginUser]       VARCHAR (32)  NULL,
    [WWTIndustry]     VARCHAR (100) NULL,
    [MediaStream]     VARCHAR (100) NULL,
    [Ethnicity]       VARCHAR (100) NULL,
    [Limit]           VARCHAR (100) NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

