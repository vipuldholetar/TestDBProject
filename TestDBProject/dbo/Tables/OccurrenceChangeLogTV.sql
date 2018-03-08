CREATE TABLE [dbo].[OccurrenceChangeLogTV] (
    [OccurrenceChangeLogTVID] INT           IDENTITY (1, 1) NOT NULL,
    [AdID]                    INT           NOT NULL,
    [Info]                    VARCHAR (500) NOT NULL,
    [EditedDT]                DATETIME      NOT NULL,
    CONSTRAINT [PK_OccurrenceChangeLogTV] PRIMARY KEY CLUSTERED ([OccurrenceChangeLogTVID] ASC)
);

