CREATE TABLE [dbo].[PatternScoringDetailTV] (
    [PatternScoringDetailTVID] INT      IDENTITY (1, 1) NOT NULL,
    [PatternStatisticID]       INT      NOT NULL,
    [PatternId]                INT      NOT NULL,
    [Score]                    INT      NULL,
    [KeyNational]              TINYINT  NULL,
    [FastLane]                 TINYINT  NULL,
    [MeetsThreshold]           TINYINT  NULL,
    [PatternVideoLength]       INT      NULL,
    [CreatedDT]                DATETIME CONSTRAINT [DF_PatternScoringDetailTV_CreatedDT] DEFAULT (getdate()) NULL,
    [ModifiedDT]               DATETIME NULL,
    PRIMARY KEY CLUSTERED ([PatternScoringDetailTVID] ASC),
    CONSTRAINT [FK_PatternScoringDetailTV_ToPattern] FOREIGN KEY ([PatternId]) REFERENCES [dbo].[Pattern] ([PatternID]),
    CONSTRAINT [FK_PatternScoringDetailTV_ToPatternStatistic] FOREIGN KEY ([PatternStatisticID]) REFERENCES [dbo].[PatternStatistic] ([PatternStatisticID])
);


GO
CREATE NONCLUSTERED INDEX [IX_PatternScoringDetailTV_PatternAndStatistic]
    ON [dbo].[PatternScoringDetailTV]([PatternId] ASC, [PatternStatisticID] ASC);

