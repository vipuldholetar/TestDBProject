CREATE TABLE [dbo].[PatternStatisticProcess] (
    [PatternStatisticProcessID] INT      IDENTITY (1, 1) NOT NULL,
    [MediaStream]               INT      NOT NULL,
    [LastProcessedDT]           DATETIME NOT NULL,
    [CreatedDT]                 DATETIME DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([PatternStatisticProcessID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PatternStatisticProcess_Media_Created]
    ON [dbo].[PatternStatisticProcess]([MediaStream] ASC, [CreatedDT] ASC);

