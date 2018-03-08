CREATE TABLE [dbo].[OccurrenceDetailCIN] (
    [OccurrenceDetailCINID] BIGINT        IDENTITY (1, 1) NOT NULL,
    [PatternID]             INT           NULL,
    [AdID]                  INT           NULL,
    [MarketID]              INT           NULL,
    [WorkType]              INT           NULL,
    [CreativeID]            VARCHAR (200) NOT NULL,
    [AirDT]                 DATETIME      NOT NULL,
    [Customer]              VARCHAR (200) NULL,
    [Rating]                VARCHAR (200) NULL,
    [Length]                INT           NOT NULL,
    [CreatedDT]             DATETIME      DEFAULT (getdate()) NOT NULL,
    [ModifiedDT]            DATETIME      NULL,
    CONSTRAINT [PK_OccurrenceDetailsCIN] PRIMARY KEY CLUSTERED ([OccurrenceDetailCINID] ASC),
    CONSTRAINT [FK_OccurrenceDetailsCIN_MARKETMASTER] FOREIGN KEY ([MarketID]) REFERENCES [dbo].[Market] ([MarketID])
);


GO
CREATE NONCLUSTERED INDEX [IDX_FK_PatternMasterId_FK_AdID_FK_MarketId]
    ON [dbo].[OccurrenceDetailCIN]([PatternID] ASC, [AdID] ASC, [MarketID] ASC)
    INCLUDE([WorkType], [CreativeID]);

