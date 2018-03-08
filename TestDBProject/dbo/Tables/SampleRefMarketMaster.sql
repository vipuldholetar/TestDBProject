CREATE TABLE [dbo].[SampleRefMarketMaster] (
    [MarketId]                          FLOAT (53)    NULL,
    [Description]                       VARCHAR (255) NULL,
    [NLSNDMAName]                       VARCHAR (255) NULL,
    [State]                             VARCHAR (255) NULL,
    [Region]                            VARCHAR (255) NULL,
    [Country]                           VARCHAR (255) NULL,
    [KimCommentMTOnlyOrMTCTStreams]     VARCHAR (255) NULL,
    [KimCommentCTOnlyStreams]           VARCHAR (255) NULL,
    [KimCommentsAdditional]             VARCHAR (255) NULL,
    [StartDT]                           DATETIME      NULL,
    [EndDT]                             VARCHAR (255) NULL,
    [CTLegacyLMKTCODE]                  VARCHAR (255) NULL,
    [CTLegacyLPRCENTCODE]               FLOAT (53)    NULL,
    [CTLegacyLTYPECODE]                 VARCHAR (255) NULL,
    [CTLegacyLWSJREGCODE]               VARCHAR (255) NULL,
    [MTLegacyMktID]                     FLOAT (53)    NULL,
    [MTLegacyRegionID]                  FLOAT (53)    NULL,
    [MTLegacyRegionDescripCODE]         VARCHAR (255) NULL,
    [MTLegacyAdamsEmailTrainingIndCODE] VARCHAR (255) NULL
);

