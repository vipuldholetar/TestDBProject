CREATE TABLE [dbo].[TMSTvEpisodes] (
    [TMSTvEpisodesID]     INT           IDENTITY (1, 1) NOT NULL,
    [CK_ProgId]           INT           NOT NULL,
    [CK_EpisodeId]        VARCHAR (20)  NOT NULL,
    [CK_EpisodeDesc]      VARCHAR (700) NOT NULL,
    [EpisodeSyndicatorId] VARCHAR (50)  NULL,
    [CreateDate]          DATETIME      NOT NULL,
    CONSTRAINT [PK_TMSTvEpisodes] PRIMARY KEY CLUSTERED ([TMSTvEpisodesID] ASC)
);

