CREATE TABLE [dbo].[OccurrenceChangeLogRA] (
    [OccurrenceChangeLogRAID] INT           IDENTITY (1, 1) NOT NULL,
    [AdID]                    INT           NOT NULL,
    [Info]                    VARCHAR (500) NOT NULL,
    [EditedDT]                DATETIME      NOT NULL,
    CONSTRAINT [PK_OccurrenceChangeLogRA] PRIMARY KEY CLUSTERED ([OccurrenceChangeLogRAID] ASC)
);

