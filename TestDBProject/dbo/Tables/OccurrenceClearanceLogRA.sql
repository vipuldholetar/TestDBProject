CREATE TABLE [dbo].[OccurrenceClearanceLogRA] (
    [OccurrenceClearanceRALogID] INT           IDENTITY (1, 1) NOT NULL,
    [OccurrenceClearanceRAID]    INT           NULL,
    [OldClearance]               VARCHAR (500) NULL,
    [OldDeleted]                 TINYINT       NULL,
    [NewClearance]               VARCHAR (500) NULL,
    [NewDeleted]                 TINYINT       NULL,
    [InsertedDT]                 DATETIME      NOT NULL,
    CONSTRAINT [PK_OCCURRENCECLEARANCERALOG] PRIMARY KEY CLUSTERED ([OccurrenceClearanceRALogID] ASC)
);

