CREATE TABLE [dbo].[TMSRawData] (
    [ProgAirDT]        DATETIME      NULL,
    [ProgStartTime]    VARCHAR (5)   NULL,
    [ProgTMSChannel]   VARCHAR (6)   NULL,
    [ProgName]         VARCHAR (255) NULL,
    [ProgDuration]     NUMERIC (3)   NULL,
    [ProgSrcType]      CHAR (1)      NULL,
    [ProgSyndicatorID] VARCHAR (15)  NULL,
    [ProgEpisodeID]    VARCHAR (20)  NULL,
    [ProgEpisodeName]  VARCHAR (255) NULL,
    [CreateDT]         DATETIME      CONSTRAINT [DF_TMSRawData_CreateDate] DEFAULT (getdate()) NOT NULL
);

