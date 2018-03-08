CREATE TABLE [dbo].[MarketMediaStream] (
    [MediaStreamId] INT NOT NULL,
    [MarketId]      INT NOT NULL,
    CONSTRAINT [PK_MarketMediaStream] PRIMARY KEY CLUSTERED ([MediaStreamId] ASC, [MarketId] ASC),
    CONSTRAINT [FK_MarketMediaStream_To_Market] FOREIGN KEY ([MarketId]) REFERENCES [dbo].[Market] ([MarketID])
);

