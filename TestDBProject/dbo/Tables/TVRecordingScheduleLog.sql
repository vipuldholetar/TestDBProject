CREATE TABLE [dbo].[TVRecordingScheduleLog] (
    [TVRecordingScheduleLogID] BIGINT        IDENTITY (1, 1) NOT NULL,
    [MasterLogID]              BIGINT        NOT NULL,
    [TVRecordingScheduleID]    INT           NULL,
    [AirDT]                    DATETIME      NULL,
    [TapeStationID]            INT           NULL,
    [MinAirTime]               VARCHAR (200) NULL,
    [MaxAirTime]               VARCHAR (200) NULL,
    CONSTRAINT [PK_TVRecordingScheduleLog] PRIMARY KEY CLUSTERED ([TVRecordingScheduleLogID] ASC)
);

