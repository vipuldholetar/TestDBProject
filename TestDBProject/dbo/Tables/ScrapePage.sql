CREATE TABLE [dbo].[ScrapePage] (
    [ScrapePageID] INT            IDENTITY (1, 1) NOT NULL,
    [PageURL]      VARCHAR (2000) NOT NULL,
    [HashURL]      AS             (CONVERT([char],hashbytes('SHA1',[PageUrl]),(2))) PERSISTED,
    [CreatedDT]    DATETIME       CONSTRAINT [DF_ScrapePage_CreateDTM] DEFAULT (getdate()) NOT NULL,
    [ModifiedDT]   DATETIME       NULL,
    [CTLegacySeq]  INT            NULL,
    CONSTRAINT [PK_ScrapePage] PRIMARY KEY CLUSTERED ([ScrapePageID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UIX_ScrapePage_HashURL]
    ON [dbo].[ScrapePage]([HashURL] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_ScrapePage_CTLegacySeq]
    ON [dbo].[ScrapePage]([CTLegacySeq] ASC);

