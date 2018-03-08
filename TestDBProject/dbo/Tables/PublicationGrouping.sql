CREATE TABLE [dbo].[PublicationGrouping] (
    [PubGroupID]    INT NOT NULL,
    [PublicationID] INT NOT NULL,
    CONSTRAINT [FK_PublicationGrouping_To_PubGroup] FOREIGN KEY ([PubGroupID]) REFERENCES [dbo].[PubGroup] ([PubGroupID]),
    CONSTRAINT [FK_PublicationGrouping_To_Publication] FOREIGN KEY ([PublicationID]) REFERENCES [dbo].[Publication] ([PublicationID])
);

