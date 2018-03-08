CREATE TABLE [dbo].[ScanTrackerScansLog] (
    [LogTimeStamp]        DATETIME     NULL,
    [LogDMLOperation]     CHAR (1)     NULL,
    [LoginUser]           VARCHAR (32) NULL,
    [ScanTrackerScansID]  INT          NULL,
    [SessionID]           INT          NULL,
    [OldVal_SessionID]    INT          NULL,
    [OccurrenceID]        BIGINT       NULL,
    [OldVal_OccurrenceID] BIGINT       NULL,
    [PageCount]           INT          NULL,
    [OldVal_PageCount]    INT          NULL,
    [PostDT]              DATETIME     NULL,
    [OldVal_PostDT]       DATETIME     NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

