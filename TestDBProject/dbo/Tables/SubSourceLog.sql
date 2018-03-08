CREATE TABLE [dbo].[SubSourceLog] (
    [LogTimeStamp]         DATETIME     NULL,
    [LogDMLOperation]      CHAR (1)     NULL,
    [LoginUser]            VARCHAR (32) NULL,
    [SubSourceID]          INT          NULL,
    [SourceID]             INT          NULL,
    [OldVal_SourceID]      INT          NULL,
    [SubSourceName]        VARCHAR (50) NULL,
    [OldVal_SubSourceName] VARCHAR (50) NULL,
    [ActiveInd]            BIT          NULL,
    [OldVal_ActiveInd]     BIT          NULL,
    [CreatedDT]            DATETIME     NULL,
    [OldVal_CreatedDT]     DATETIME     NULL,
    [CreatedByID]          INT          NULL,
    [OldVal_CreatedByID]   INT          NULL,
    [ModifiedDT]           DATETIME     NULL,
    [OldVal_ModifiedDT]    DATETIME     NULL,
    [ModifiedByID]         INT          NULL,
    [OldVal_ModifiedByID]  INT          NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

