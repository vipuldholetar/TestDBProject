CREATE TYPE [dbo].[TMSData] AS TABLE (
    [ProgAirDate]      DATETIME      NULL,
    [ProgStartTime]    VARCHAR (5)   NULL,
    [ProgTMSChannel]   VARCHAR (6)   NULL,
    [ProgName]         VARCHAR (MAX) NULL,
    [ProgDuration]     NUMERIC (3)   NULL,
    [ProgSrcType]      CHAR (1)      NULL,
    [ProgSyndicatorId] VARCHAR (15)  NULL,
    [ProgEpisodeId]    VARCHAR (20)  NULL,
    [ProgEpisodeName]  VARCHAR (MAX) NULL);

