CREATE TABLE [dbo].[OccurrenceClearanceRejectedLogTV] (
    [OccurrenceClearanceTVRejectedLogID] INT           IDENTITY (1, 1) NOT NULL,
    [OccurrenceClearanceTVID]            INT           NOT NULL,
    [Reason]                             VARCHAR (500) NULL,
    [CreateDT]                           DATETIME2 (7) NOT NULL,
    CONSTRAINT [PK_OCCURRENCECLEATVNCETVREJECTEDLOG] PRIMARY KEY CLUSTERED ([OccurrenceClearanceTVRejectedLogID] ASC)
);

