CREATE TABLE [dbo].[ScanTrackerLog] (
    [LogTimeStamp]        DATETIME     NULL,
    [LogDMLOperation]     CHAR (1)     NULL,
    [LoginUser]           VARCHAR (32) NULL,
    [ScanTrackerID]       INT          NULL,
    [UserID]              INT          NULL,
    [OldVal_UserID]       INT          NULL,
    [ScanTrackDT]         DATETIME     NULL,
    [OldVal_ScanTrackDT]  DATETIME     NULL,
    [OccurrenceID]        BIGINT       NULL,
    [OldVal_OccurrenceID] BIGINT       NULL,
    [ImageName]           VARCHAR (50) NULL,
    [OldVal_ImageName]    VARCHAR (50) NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

