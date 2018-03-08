CREATE TABLE [dbo].[MTGMarketStatistic] (
    [MTGMarketStatisticID] INT             NOT NULL,
    [MTGMarketID]          INT             NOT NULL,
    [Percentage]           NUMERIC (16, 4) NULL,
    [Population]           NUMERIC (16)    NULL,
    [DMARank]              NUMERIC (16)    NULL,
    [TVHouseHolds]         NUMERIC (16)    NULL,
    [NielsenDMAName]       VARCHAR (50)    NULL,
    [EffectiveStartDT]     DATE            NOT NULL,
    [EffectiveEndDT]       DATE            NOT NULL,
    CONSTRAINT [PK_MTGMarketStatistics] PRIMARY KEY CLUSTERED ([MTGMarketStatisticID] ASC),
    CONSTRAINT [FK_MTGMarketStatistics_MTGMarket] FOREIGN KEY ([MTGMarketID]) REFERENCES [dbo].[MTGMarket] ([MTGMarketID])
);

