CREATE TABLE [dbo].[TVProgramTypeLog] (
    [LogTimeStamp]             DATETIME     NULL,
    [LogDMLOperation]          CHAR (1)     NULL,
    [LoginUser]                VARCHAR (32) NULL,
    [TVProgramTypeCode]        VARCHAR (1)  NULL,
    [TVProgramTypeName]        VARCHAR (50) NULL,
    [OldVal_TVProgramTypeName] VARCHAR (50) NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

