CREATE TABLE [dbo].[SourceURLLog] (
    [LogTimeStamp]     DATETIME       NULL,
    [LogDMLOperation]  CHAR (1)       NULL,
    [LoginUser]        VARCHAR (32)   NULL,
    [SourceURLID]      INT            NULL,
    [SourceURL]        VARCHAR (1000) NULL,
    [OldVal_SourceURL] VARCHAR (1000) NULL,
    [HashURL]          CHAR (30)      NULL,
    [OldVal_HashURL]   CHAR (30)      NULL,
    [CreatedDT]        DATETIME       NULL,
    [OldVal_CreatedDT] DATETIME       NULL,
    [CTLegacySeq]      INT            NULL,
    [Old_CTLegacySeq]  INT            NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

