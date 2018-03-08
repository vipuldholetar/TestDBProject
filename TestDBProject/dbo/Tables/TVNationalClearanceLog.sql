CREATE TABLE [dbo].[TVNationalClearanceLog] (
    [LogTimeStamp]           DATETIME     NULL,
    [LogDMLOperation]        CHAR (1)     NULL,
    [LoginUser]              VARCHAR (32) NULL,
    [TVNationalClearanceID]  INT          NULL,
    [Clearance]              VARCHAR (50) NULL,
    [OldVal_Clearance]       VARCHAR (50) NULL,
    [ClearanceMethod]        CHAR (1)     NULL,
    [OldVal_ClearanceMethod] CHAR (1)     NULL,
    [AirDate]                DATE         NULL,
    [OldVal_AirDate]         DATE         NULL,
    [AirTime]                TIME (7)     NULL,
    [OldVal_AirTime]         TIME (7)     NULL,
    [ProgramID]              INT          NULL,
    [OldVal_ProgramID]       INT          NULL,
    [EpisodeID]              VARCHAR (20) NULL,
    [OldVal_EpisodeID]       VARCHAR (20) NULL,
    [MatchupID]              INT          NULL,
    [OldVal_MatchupID]       INT          NULL,
    [ElapsedTime]            INT          NULL,
    [OldVal_ElapsedTime]     INT          NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

