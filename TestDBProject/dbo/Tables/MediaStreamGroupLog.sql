CREATE TABLE [dbo].[MediaStreamGroupLog] (
    [LogTimeStamp]            DATETIME     NULL,
    [LogDMLOperation]         CHAR (1)     NULL,
    [LoginUser]               VARCHAR (32) NULL,
    [MediaStreamGroupID]      INT          NULL,
    [MediaStreamGroup]        VARCHAR (50) NULL,
    [OldVal_MediaStreamGroup] VARCHAR (50) NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

