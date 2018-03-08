CREATE TABLE [dbo].[TVNewAdDataLog] (
    [LogTimeStamp]      DATETIME      NULL,
    [LogDMLOperation]   CHAR (1)      NULL,
    [LoginUser]         VARCHAR (32)  NULL,
    [TVNewAdDataID]     INT           NULL,
    [AdFileData]        VARCHAR (MAX) NULL,
    [OldVal_AdFileData] VARCHAR (MAX) NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

