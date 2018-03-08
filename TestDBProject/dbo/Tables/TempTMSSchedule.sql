CREATE TABLE [dbo].[TempTMSSchedule] (
    [TempTMSScheduleID] INT          IDENTITY (1, 1) NOT NULL,
    [TMSSeqID]          INT          NULL,
    [TMSStationID]      INT          NULL,
    [MTAirDT]           DATETIME     NOT NULL,
    [TMSEpisodeID]      VARCHAR (20) NOT NULL,
    [QtrScheduleID]     INT          NOT NULL,
    [SrcType]           VARCHAR (4)  NULL
);

