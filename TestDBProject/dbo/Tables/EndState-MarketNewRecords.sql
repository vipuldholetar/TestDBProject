CREATE TABLE [dbo].[EndState-MarketNewRecords] (
    [MarketId]                               VARCHAR (50) NULL,
    [Description]                            VARCHAR (50) NULL,
    [NielsenDMAName]                         VARCHAR (50) NULL,
    [State]                                  VARCHAR (50) NULL,
    [Region]                                 VARCHAR (50) NULL,
    [Country]                                VARCHAR (50) NULL,
    [DisplayMarket]                          VARCHAR (50) NULL,
    [Promotion]                              VARCHAR (50) NULL,
    [Brand]                                  VARCHAR (50) NULL,
    [IngestData]                             VARCHAR (50) NULL,
    [Start Date]                             VARCHAR (50) NULL,
    [EndDate]                                VARCHAR (50) NULL,
    [FK_CTLegacyLMKTCOD]                     VARCHAR (50) NULL,
    [FK_CTLegacyLPRCENT]                     VARCHAR (50) NULL,
    [FK_CTLegacyLTYPE]                       VARCHAR (50) NULL,
    [FK_CTLegacyLWSJREG]                     VARCHAR (50) NULL,
    [FK_MTLegacyMktId]                       VARCHAR (50) NULL,
    [FK_MTLegacyRegionId]                    VARCHAR (50) NULL,
    [FK_MTLegacyRegionDescription]           VARCHAR (50) NULL,
    [FK_MTLegacyAdamsEmailTrainingIndicator] VARCHAR (50) NULL,
    [MarketID_RetiringRow]                   VARCHAR (50) NULL
);

