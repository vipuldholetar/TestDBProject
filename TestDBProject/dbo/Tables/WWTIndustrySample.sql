CREATE TABLE [dbo].[WWTIndustrySample] (
    [WWTIndustryName]                 VARCHAR (100)  NULL,
    [LegacyIndustryGroup ]            VARCHAR (100)  NULL,
    [SanityCheck1]                    VARCHAR (100)  NULL,
    [SanityCheck2]                    VARCHAR (100)  NULL,
    [attemptAdvRegistrationIndicator] VARCHAR (50)   NULL,
    [allowAdvRegistrationIndicator]   VARCHAR (50)   NULL,
    [MTLegacyTradeClass]              VARCHAR (50)   NULL,
    [Notes]                           VARCHAR (1000) NULL,
    [DANotes]                         VARCHAR (1000) NULL,
    [defaultLegacyIndustryGroup]      VARCHAR (100)  NULL
);

