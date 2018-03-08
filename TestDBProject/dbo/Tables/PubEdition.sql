CREATE TABLE [dbo].[PubEdition] (
    [PubEditionID]  INT          IDENTITY (1, 1) NOT NULL,
    [PublicationID] INT          NOT NULL,
    [LanguageID]    INT          NOT NULL,
    [MarketID]      INT          NOT NULL,
    [EditionName]   VARCHAR (50) NOT NULL,
    [MNIInd]        TINYINT      NULL,
    [DefaultInd]    TINYINT      NOT NULL,
    [CreatedDT]     DATETIME     NOT NULL,
    [CreatedByID]   INT          NOT NULL,
    [ModifiedDT]    DATETIME     NULL,
    [ModifiedByID]  INT          NULL,
    CONSTRAINT [PK_PubEdition] PRIMARY KEY CLUSTERED ([PubEditionID] ASC),
    CONSTRAINT [FK_PubEdition_LANGUAGEMASTER] FOREIGN KEY ([LanguageID]) REFERENCES [dbo].[Language] ([LanguageID]),
    CONSTRAINT [FK_PubEdition_Publication] FOREIGN KEY ([PublicationID]) REFERENCES [dbo].[Publication] ([PublicationID])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key in PubEdition ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PubEdition', @level2type = N'COLUMN', @level2name = N'PubEditionID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'This is for Multi Edition.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PubEdition', @level2type = N'COLUMN', @level2name = N'MNIInd';

