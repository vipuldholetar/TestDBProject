CREATE TABLE [dbo].[MTCINMarketMap] (
    [MTCINMarketMapID] INT           IDENTITY (1, 1) NOT NULL,
    [MTMarketID]       INT           NOT NULL,
    [NCMMarketID]      VARCHAR (200) NOT NULL,
    [EffectiveStartDT] DATETIME      NULL,
    [EffectiveEndDT]   DATETIME      NULL,
    [CreatedDT]        DATETIME      NOT NULL,
    [CreatedByID]      INT           NOT NULL,
    [ModifiedDT]       DATETIME      NULL,
    [ModifiedByID]     INT           NULL,
    CONSTRAINT [PK_MTCINMarketMap] PRIMARY KEY CLUSTERED ([MTCINMarketMapID] ASC),
    CONSTRAINT [FK_MTCINMarketMap_MARKETMASTER] FOREIGN KEY ([MTMarketID]) REFERENCES [dbo].[Market] ([MarketID])
);

