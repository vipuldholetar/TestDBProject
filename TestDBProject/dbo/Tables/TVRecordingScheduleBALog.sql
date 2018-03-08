CREATE TABLE [dbo].[TVRecordingScheduleBALog] (
    [LogTimeStamp]            DATETIME       NULL,
    [LogDMLOperation]         CHAR (1)       NULL,
    [LoginUser]               VARCHAR (32)   NULL,
    [TVRecordingScheduleBAID] FLOAT (53)     NULL,
    [MTStationID]             NVARCHAR (255) NULL,
    [CaptureStationCode]      NVARCHAR (255) NULL,
    [Weekdays]                NVARCHAR (255) NULL,
    [EffectiveStartDT]        DATETIME       NULL,
    [EffectiveEndDT]          NVARCHAR (255) NULL,
    [StartDT]                 DATETIME       NULL,
    [EndDT]                   DATETIME       NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

