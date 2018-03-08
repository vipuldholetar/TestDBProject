CREATE TABLE [dbo].[EndState-Market] (
    [MarketId]                               VARCHAR (50)  NULL,
    [Description]                            VARCHAR (50)  NULL,
    [NielsenDMAName]                         VARCHAR (50)  NULL,
    [State]                                  VARCHAR (50)  NULL,
    [Region]                                 VARCHAR (50)  NULL,
    [Country]                                VARCHAR (50)  NULL,
    [Display Market in Select Media Streams] VARCHAR (100) NULL,
    [Promotion (Translation Only)]           VARCHAR (50)  NULL,
    [Brand (Translation Only)]               VARCHAR (100) NULL,
    [Start Date]                             VARCHAR (50)  NULL,
    [EndDate]                                VARCHAR (50)  NULL,
    [FK_CTLegacyLMKTCOD]                     VARCHAR (50)  NULL,
    [FK_CTLegacyLPRCENT]                     VARCHAR (50)  NULL,
    [FK_CTLegacyLTYPE]                       VARCHAR (50)  NULL,
    [FK_CTLegacyLWSJREG]                     VARCHAR (50)  NULL,
    [FK_MTLegacyMktId]                       VARCHAR (50)  NULL,
    [FK_MTLegacyRegionId]                    VARCHAR (50)  NULL,
    [FK_MTLegacyRegionDescription]           VARCHAR (50)  NULL,
    [FK_MTLegacyAdamsEmailTrainingIndicator] VARCHAR (50)  NULL,
    [Market ID (retiring row)]               VARCHAR (50)  NULL
);

