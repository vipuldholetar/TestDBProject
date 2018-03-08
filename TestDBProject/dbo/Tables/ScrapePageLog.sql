CREATE TABLE [dbo].[ScrapePageLog] (
    [LogTimeStamp]      DATETIME       NULL,
    [LogDMLOperation]   CHAR (1)       NULL,
    [LoginUser]         VARCHAR (32)   NULL,
    [ScrapePageID]      INT            NULL,
    [PageURL]           VARCHAR (2000) NULL,
    [OldVal_PageURL]    VARCHAR (2000) NULL,
    [HashURL]           CHAR (30)      NULL,
    [OldVal_HashURL]    CHAR (30)      NULL,
    [CreatedDT]         DATETIME       NULL,
    [OldVal_CreatedDT]  DATETIME       NULL,
    [ModifiedDT]        DATETIME       NULL,
    [OldVal_ModifiedDT] DATETIME       NULL,
    [CTLegacySeq]       INT            NULL,
    [Old_CTLegacySeq]   INT            NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

