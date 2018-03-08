CREATE TABLE [dbo].[RuleTypeLog] (
    [LogTimeStamp]    DATETIME     NULL,
    [LogDMLOperation] CHAR (1)     NULL,
    [LoginUser]       VARCHAR (32) NULL,
    [RuleTypeID]      INT          NULL,
    [RuleType]        VARCHAR (50) NULL,
    [OldVal_RuleType] VARCHAR (50) NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

