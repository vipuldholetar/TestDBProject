CREATE TABLE [dbo].[PatternStatistic] (
    [PatternStatisticID] INT        IDENTITY (1, 1) NOT NULL,
    [PatternID]          INT        NOT NULL,
    [TotalOccrncCount]   INT        NULL,
    [FirstRunDT]         DATETIME   NULL,
    [LastRunDT]          DATETIME   NULL,
    [TotalSpend]         FLOAT (53) NULL,
    [FirstMediaOutletID] INT        NULL,
    [CreatedDT]          DATETIME   CONSTRAINT [DF_PatternStatistic_CreatedDT] DEFAULT (getdate()) NULL,
    [ModifiedDT]         DATETIME   NULL,
    CONSTRAINT [PK_PatternStatistics_1] PRIMARY KEY CLUSTERED ([PatternStatisticID] ASC),
    CONSTRAINT [FK_PatternStatistic_Pattern] FOREIGN KEY ([PatternID]) REFERENCES [dbo].[Pattern] ([PatternID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PatternStatistic_PatternID]
    ON [dbo].[PatternStatistic]([PatternID] ASC);

