CREATE TABLE [dbo].[TVRecordingSchedule] (
    [TVRecordingScheduleID]     INT           IDENTITY (1, 1) NOT NULL,
    [TVStationID]               INT           NOT NULL,
    [WeekDays]                  VARCHAR (200) NOT NULL,
    [CaptureStationCode]        VARCHAR (200) NULL,
    [EffectiveStartDT]          DATETIME      NULL,
    [EffectiveEndDT]            DATETIME      NULL,
    [StartDT]                   TIME (7)      NOT NULL,
    [EndDT]                     TIME (7)      NOT NULL,
    [RemoteCapture]             VARCHAR (200) NULL,
    [FastTrack]                 VARCHAR (200) NULL,
    [MCQAiringNeeded]           INT           NULL,
    [PostToAds]                 VARCHAR (200) NULL,
    [LegacyRecordingScheduleID] INT           NULL,
    CONSTRAINT [PK_TVRecordingSchedule] PRIMARY KEY CLUSTERED ([TVRecordingScheduleID] ASC)
);

