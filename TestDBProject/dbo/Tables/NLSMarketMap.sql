CREATE TABLE [dbo].[NLSMarketMap] (
    [MapId]               INT          IDENTITY (1, 1) NOT NULL,
    [MapType]             VARCHAR (50) NULL,
    [NielsenMarketCode]   VARCHAR (50) NULL,
    [FK_DMAId]            INT          NULL,
    [FK_NielsenStationId] INT          NULL,
    [FK_MTStationId]      INT          NULL,
    [IsTracked]           VARCHAR (3)  NOT NULL,
    [CreatedDate]         DATETIME     NOT NULL,
    [FK_CreatedBy]        INT          NOT NULL,
    [ModifiedDate]        DATETIME     NULL,
    [ModifiedBy]          INT          NULL,
    CONSTRAINT [PK_NLSMarketMap] PRIMARY KEY CLUSTERED ([MapId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'This table holds the mappings between MT Market Code (DMA) and Nielsen market codes, also Nielsen station codes and MT station codes.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NLSMarketMap';

