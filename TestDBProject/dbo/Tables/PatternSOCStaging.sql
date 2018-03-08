CREATE TABLE [dbo].[PatternSOCStaging] (
    [PatternSOCStagingID] INT      IDENTITY (1, 1) NOT NULL,
    [CreativeStagingID]   INT      NOT NULL,
    [OccurrenceID]        INT      NOT NULL,
    [TotalQScore]         INT      NULL,
    [ScoreQ]              INT      NULL,
    [LanguageID]          INT      NOT NULL,
    [Exception]           TINYINT  NULL,
    [Query]               TINYINT  NULL,
    [CreatedDT]           DATETIME NOT NULL,
    [CreatedByID]         INT      NOT NULL,
    [ModifiedDT]          DATETIME NULL,
    [ModifiedByID]        INT      NULL
);

