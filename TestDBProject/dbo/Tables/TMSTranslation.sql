CREATE TABLE [dbo].[TMSTranslation] (
    [EthnicGrpID]      INT           NULL,
    [ProgAirDT]        DATETIME      NULL,
    [ProgStartTime]    VARCHAR (5)   NULL,
    [ProgTMSChannel]   VARCHAR (6)   NULL,
    [ProgName]         VARCHAR (255) NULL,
    [ProgDuration]     NUMERIC (3)   NULL,
    [ProgSrcType]      CHAR (1)      NULL,
    [ProgSyndicatorID] VARCHAR (15)  NULL,
    [ProgEpisodeID]    VARCHAR (20)  NULL,
    [ProgEpisodeName]  VARCHAR (255) NULL,
    [CreateDT]         DATETIME      CONSTRAINT [DF_TMSTranslation_CreateDate] DEFAULT (getdate()) NOT NULL,
    [TMSTranslationID] INT           IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [PK_TMSTranslation] PRIMARY KEY CLUSTERED ([TMSTranslationID] ASC)
);

