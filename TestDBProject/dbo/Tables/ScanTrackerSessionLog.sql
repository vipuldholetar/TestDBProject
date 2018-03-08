CREATE TABLE [dbo].[ScanTrackerSessionLog] (
    [LogTimeStamp]         DATETIME     NULL,
    [LogDMLOperation]      CHAR (1)     NULL,
    [LoginUser]            VARCHAR (32) NULL,
    [ScanTrackerSessionID] INT          NULL,
    [UserID]               INT          NULL,
    [OldVal_UserID]        INT          NULL,
    [StartDT]              DATETIME     NULL,
    [OldVal_StartDT]       DATETIME     NULL,
    [EndDT]                DATETIME     NULL,
    [OldVal_EndDT]         DATETIME     NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

