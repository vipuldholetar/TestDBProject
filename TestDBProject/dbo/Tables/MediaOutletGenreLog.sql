CREATE TABLE [dbo].[MediaOutletGenreLog] (
    [LogTimeStamp]       DATETIME      NULL,
    [LogDMLOperation]    CHAR (1)      NULL,
    [LoginUser]          VARCHAR (32)  NULL,
    [MediaOutletGenreID] INT           NULL,
    [GenreName]          VARCHAR (100) NULL,
    [OldVal_GenreName]   VARCHAR (100) NULL,
    [CreatedDT]          DATETIME      NULL,
    [OldVal_CreatedDT]   DATETIME      NULL,
    [ModifiedDT]         DATETIME      NULL,
    [OldVal_ModifiedDT]  DATETIME      NULL,
    [CTLegacySeq]        INT           NULL,
    [OldVal_CTLegacySeq] INT           NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

