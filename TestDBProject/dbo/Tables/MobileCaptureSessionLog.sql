CREATE TABLE [dbo].[MobileCaptureSessionLog] (
    [LogTimeStamp]                 DATETIME     NULL,
    [LogDMLOperation]              CHAR (1)     NULL,
    [LoginUser]                    VARCHAR (32) NULL,
    [MobileCaptureSessionID]       INT          NULL,
    [MobileJobScheduleID]          INT          NULL,
    [OldVal_MobileJobScheduleID]   INT          NULL,
    [CaptureStartDT]               DATETIME     NULL,
    [OldVal_CaptureStartDT]        DATETIME     NULL,
    [CaptureEndDT]                 DATETIME     NULL,
    [OldVal_CaptureEndDT]          DATETIME     NULL,
    [MobileTrackingMediaID]        INT          NULL,
    [OldVal_MobileTrackingMediaID] INT          NULL,
    [NodeID]                       INT          NULL,
    [OldVal_NodeID]                INT          NULL,
    [MobileDeviceID]               INT          NULL,
    [OldVal_MobileDeviceID]        INT          NULL,
    [CTLegacySeq]                  INT          NULL,
    [OldVal_CTLegacySeq]           INT          NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

