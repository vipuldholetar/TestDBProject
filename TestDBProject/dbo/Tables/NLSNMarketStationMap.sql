CREATE TABLE [dbo].[NLSNMarketStationMap] (
    [NLSNMarketStationMapID] INT          IDENTITY (1, 1) NOT NULL,
    [MapType]                VARCHAR (50) NULL,
    [NLSNMarketCode]         VARCHAR (50) NULL,
    [NLSNDMACode]            VARCHAR (50) NULL,
    [MarketID]               INT          NULL,
    [NLSNStationID]          INT          NULL,
    [NLSNStationName]        VARCHAR (5)  NULL,
    [TVStationID]            INT          NULL,
    [Tracked]                TINYINT      NULL,
    [CreatedDT]              DATETIME     NULL,
    [CreatedByID]            INT          NULL,
    [ModifiedDT]             DATETIME     NULL,
    [ModifiedByID]           INT          NULL,
    CONSTRAINT [PK_NLSNMarketStationMap] PRIMARY KEY CLUSTERED ([NLSNMarketStationMapID] ASC),
    CONSTRAINT [FK_NLSNMarketStationMap_To_Market] FOREIGN KEY ([MarketID]) REFERENCES [dbo].[Market] ([MarketID]),
    CONSTRAINT [FK_NLSNMarketStationMap_To_TVStation] FOREIGN KEY ([TVStationID]) REFERENCES [dbo].[TVStation] ([TVStationID])
);

