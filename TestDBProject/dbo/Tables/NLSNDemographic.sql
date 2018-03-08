CREATE TABLE [dbo].[NLSNDemographic] (
    [NLSNDemographicID]  INT           IDENTITY (1, 1) NOT NULL,
    [DemographicDescrip] VARCHAR (100) NOT NULL,
    [Tracked]            VARCHAR (3)   NOT NULL,
    [CreatedDT]          DATETIME      NOT NULL,
    [CreatedByID]        INT           NOT NULL,
    [ModifiedDT]         DATETIME      NOT NULL,
    [ModifiedByID]       INT           NOT NULL,
    CONSTRAINT [PK_NLSDemographics] PRIMARY KEY CLUSTERED ([NLSNDemographicID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'This table will hold all the possible demographics ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NLSNDemographic';

