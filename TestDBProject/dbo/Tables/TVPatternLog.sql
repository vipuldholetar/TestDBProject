CREATE TABLE [dbo].[TVPatternLog] (
    [LogTimeStamp]          DATETIME      NULL,
    [LogDMLOperation]       CHAR (1)      NULL,
    [LoginUser]             VARCHAR (32)  NULL,
    [TVPatternCODE]         VARCHAR (200) NULL,
    [OriginalPRCode]        VARCHAR (200) NULL,
    [OldVal_OriginalPRCode] VARCHAR (200) NULL,
    [SrcFileName]           VARCHAR (200) NULL,
    [OldVal_SrcFileName]    VARCHAR (200) NULL,
    [Priority]              INT           NULL,
    [OldVal_Priority]       INT           NULL,
    [WorkType]              INT           NULL,
    [OldVal_WorkType]       INT           NULL,
    [CreatedDT]             DATETIME      NULL,
    [OldVal_CreatedDT]      DATETIME      NULL,
    [CreatedByID]           INT           NULL,
    [OldVal_CreatedByID]    INT           NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

