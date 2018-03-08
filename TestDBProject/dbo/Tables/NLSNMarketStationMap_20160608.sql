CREATE TABLE [dbo].[NLSNMarketStationMap_20160608] (
    [NLSNMarketStationMapID] INT          IDENTITY (1, 1) NOT NULL,
    [MapType]                VARCHAR (50) NULL,
    [NLSNMarketCode]         VARCHAR (50) NULL,
    [NLSNDMACode]            VARCHAR (50) NULL,
    [MTMarketID]             INT          NULL,
    [NLSNStationID]          VARCHAR (50) NULL,
    [MTStationID]            INT          NULL,
    [Tracked]                TINYINT      NULL,
    [CreatedDT]              DATETIME     NULL,
    [CreatedByID]            INT          NULL,
    [ModifiedDT]             DATETIME     NULL,
    [ModifiedByID]           INT          NULL
);

