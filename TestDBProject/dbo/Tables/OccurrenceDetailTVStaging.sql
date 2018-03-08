CREATE TABLE [dbo].[OccurrenceDetailTVStaging] (
    [OccurrenceDetailTVID]  BIGINT        IDENTITY (1, 1) NOT NULL,
    [PatternMasterID]       INT           NULL,
    [AdID]                  INT           NULL,
    [TVRecordingScheduleID] INT           NOT NULL,
    [PRCODE]                VARCHAR (200) NOT NULL,
    [AirDT]                 DATETIME      NOT NULL,
    [AirTime]               DATETIME      NOT NULL,
    [AdLength]              NUMERIC (18)  NOT NULL,
    [CaptureStationCode]    VARCHAR (200) NULL,
    [InputFileName]         VARCHAR (200) NULL,
    [CaptureDT]             DATETIME      NULL,
    [CreatedDT]             DATETIME      NOT NULL,
    [TVProgramID]           VARCHAR (200) NULL,
    [TVEpisodeID]           NUMERIC (18)  NULL,
    [Deleted]               TINYINT       NULL,
    [FakePatternCODE]       INT           NULL,
    [CTLegacySeq]           INT           NULL,
    CONSTRAINT [PK_OccurrenceDetailsTVStaging] PRIMARY KEY CLUSTERED ([OccurrenceDetailTVID] ASC)
);

