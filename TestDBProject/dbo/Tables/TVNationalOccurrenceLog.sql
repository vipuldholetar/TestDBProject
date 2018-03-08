CREATE TABLE [dbo].[TVNationalOccurrenceLog] (
    [LogTimeStamp]            DATETIME     NULL,
    [LogDMLOperation]         CHAR (1)     NULL,
    [LoginUser]               VARCHAR (32) NULL,
    [TVNationalOccurrenceId]  INT          NULL,
    [NationalID]              INT          NULL,
    [OldVal_NationalID]       INT          NULL,
    [MatchupID]               INT          NULL,
    [OldVal_MatchupID]        INT          NULL,
    [StationNetworkID]        INT          NULL,
    [OldVal_StationNetworkID] INT          NULL,
    [AirDate]                 DATE         NULL,
    [OldVal_AirDate]          DATE         NULL,
    [AirTime]                 TIME (7)     NULL,
    [OldVal_AirTime]          TIME (7)     NULL,
    [ProgramID]               INT          NULL,
    [OldVal_ProgramID]        INT          NULL,
    [EpisodeID]               VARCHAR (20) NULL,
    [OldVal_EpisodeID]        VARCHAR (20) NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

