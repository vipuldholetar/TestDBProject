CREATE TABLE [dbo].[SourceURL] (
    [SourceURLID] INT            IDENTITY (1, 1) NOT NULL,
    [SourceURL]   VARCHAR (1000) NOT NULL,
    [HashURL]     AS             (CONVERT([char],hashbytes('SHA1',[SourceURL]),(2))) PERSISTED,
    [CreatedDT]   DATETIME       DEFAULT (getdate()) NULL,
    [CTLegacySeq] INT            NULL,
    CONSTRAINT [PK_SourceURL] PRIMARY KEY CLUSTERED ([SourceURLID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UIX_SourceURL_HashURL]
    ON [dbo].[SourceURL]([HashURL] ASC);

