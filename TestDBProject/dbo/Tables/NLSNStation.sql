CREATE TABLE [dbo].[NLSNStation] (
    [NLSNStationID] INT           IDENTITY (1, 1) NOT NULL,
    [StationName]   VARCHAR (100) NOT NULL,
    [CreatedDT]     DATETIME      NOT NULL,
    [CreatedByID]   INT           NOT NULL,
    [ModifiedDT]    DATETIME      NOT NULL,
    [ModifiedByID]  INT           NOT NULL,
    CONSTRAINT [PK_NLSStationMst] PRIMARY KEY CLUSTERED ([NLSNStationID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'A Station master table for Nielsen', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NLSNStation';

