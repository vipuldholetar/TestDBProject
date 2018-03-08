CREATE TABLE [dbo].[OccurrenceClearanceLogTV] (
    [OccurrenceClearanceTVLogID] INT           IDENTITY (1, 1) NOT NULL,
    [OccurrenceClearanceTVID]    INT           NULL,
    [OldClearance]               VARCHAR (500) NULL,
    [OldDeleted]                 TINYINT       NULL,
    [NewClearance]               VARCHAR (500) NULL,
    [NewDeleted]                 TINYINT       NULL,
    [InsertedDT]                 DATETIME      NOT NULL,
    CONSTRAINT [PK_OCCURRENCECLEATVNCETVLOG] PRIMARY KEY CLUSTERED ([OccurrenceClearanceTVLogID] ASC)
);

