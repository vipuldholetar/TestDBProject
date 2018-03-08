CREATE TABLE [dbo].[MTODRFormatLog] (
    [LogTimeStamp]         DATETIME       NULL,
    [LogDMLOperation]      CHAR (1)       NULL,
    [LoginUser]            VARCHAR (32)   NULL,
    [MTODRFormatID]        INT            NULL,
    [FormatDescrip]        VARCHAR (1000) NULL,
    [OldVal_FormatDescrip] VARCHAR (1000) NULL,
    [CreatedDT]            DATETIME       NULL,
    [OldVal_CreatedDT]     DATETIME       NULL,
    [CreatedByID]          INT            NULL,
    [OldVal_CreatedByID]   INT            NULL,
    [ModifiedDT]           DATETIME       NULL,
    [OldVal_ModifiedDT]    DATETIME       NULL,
    [ModifiedByID]         INT            NULL,
    [OldVal_ModifiedByID]  INT            NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

