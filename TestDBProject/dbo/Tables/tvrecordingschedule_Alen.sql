CREATE TABLE [dbo].[tvrecordingschedule_Alen] (
    [PK_Id]              INT           IDENTITY (1, 1) NOT NULL,
    [FK_MTStationId]     INT           NOT NULL,
    [WeekDays]           VARCHAR (200) NOT NULL,
    [CaptureStationCode] VARCHAR (200) NULL,
    [EffectiveStartDate] DATETIME      NULL,
    [EffectiveEndTime]   DATETIME      NULL,
    [StartTime]          DATETIME      NOT NULL,
    [EndTime]            DATETIME      NOT NULL,
    [RemoteCapture]      VARCHAR (200) NULL,
    [FastTrack]          VARCHAR (200) NULL,
    [MCQAiringNeeded]    INT           NULL,
    [PostToAds]          VARCHAR (200) NULL
);

