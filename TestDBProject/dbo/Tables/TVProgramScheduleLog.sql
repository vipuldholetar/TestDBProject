CREATE TABLE [dbo].[TVProgramScheduleLog] (
    [LogTimeStamp]         DATETIME     NULL,
    [LogDMLOperation]      CHAR (1)     NULL,
    [LoginUser]            VARCHAR (32) NULL,
    [TVProgramScheduleID]  INT          NULL,
    [MTProgramID]          INT          NULL,
    [OldVal_MTProgramID]   INT          NULL,
    [MTStationID]          INT          NULL,
    [OldVal_MTStationID]   INT          NULL,
    [MTAirDT]              DATETIME     NULL,
    [OldVal_MTAirDT]       DATETIME     NULL,
    [TMSEpisodeID]         VARCHAR (20) NULL,
    [OldVal_TMSEpisodeID]  VARCHAR (20) NULL,
    [QtrScheduleID]        INT          NULL,
    [OldVal_QtrScheduleID] INT          NULL,
    [MTSrcType]            VARCHAR (4)  NULL,
    [OldVal_MTSrcType]     VARCHAR (4)  NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

