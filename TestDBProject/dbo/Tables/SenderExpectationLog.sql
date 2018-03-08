CREATE TABLE [dbo].[SenderExpectationLog] (
    [LogTimeStamp]    DATETIME     NULL,
    [LogDMLOperation] CHAR (1)     NULL,
    [LoginUser]       VARCHAR (32) NULL,
    [SenderID]        INT          NULL,
    [ExpectationID]   INT          NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

