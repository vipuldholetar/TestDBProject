CREATE TABLE [dbo].[RawTVNewAdErrorLog] (
    [LogTimeStamp]           DATETIME      NULL,
    [LogDMLOperation]        CHAR (1)      NULL,
    [LoginUser]              VARCHAR (32)  NULL,
    [RawTVNewAdErrorID]      BIGINT        NULL,
    [PatternCODE]            VARCHAR (200) NULL,
    [OldVal_PatternCODE]     VARCHAR (200) NULL,
    [InputFileName]          VARCHAR (200) NULL,
    [OldVal_InputFileName]   VARCHAR (200) NULL,
    [Length]                 INT           NULL,
    [OldVal_Length]          INT           NULL,
    [Priority]               INT           NULL,
    [OldVal_Priority]        INT           NULL,
    [CreatedDT]              DATETIME      NULL,
    [OldVal_CreatedDT]       DATETIME      NULL,
    [IngestionDT]            DATETIME      NULL,
    [OldVal_IngestionDT]     DATETIME      NULL,
    [IngestionStatus]        INT           NULL,
    [OldVal_IngestionStatus] INT           NULL,
    [Station]                VARCHAR (4)   NULL,
    [OldVal_Station]         VARCHAR (4)   NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

