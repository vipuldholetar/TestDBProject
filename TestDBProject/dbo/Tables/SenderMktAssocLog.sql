CREATE TABLE [dbo].[SenderMktAssocLog] (
    [LogTimeStamp]    DATETIME     NULL,
    [LogDMLOperation] CHAR (1)     NULL,
    [LoginUser]       VARCHAR (32) NULL,
    [SenderID]        INT          NULL,
    [MktID]           INT          NULL,
    [OldVal_MktID]    INT          NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

