CREATE TABLE [dbo].[MediaIrisCompetitrackAppMap] (
    [AppMapID]         INT      NOT NULL,
    [MediaIrisAppID]   INT      NOT NULL,
    [MobileAppID]      INT      NOT NULL,
    [EffectiveStartDT] DATE     NOT NULL,
    [EffectiveEndDT]   DATE     NOT NULL,
    [CreatedDT]        DATETIME CONSTRAINT [DF_MediaIrisCompetitrackAppMap_CreateDTM] DEFAULT (getdate()) NOT NULL,
    [ModifiedDT]       DATETIME NULL,
    CONSTRAINT [PK_MediaIrisCompetitrackAppMap] PRIMARY KEY CLUSTERED ([AppMapID] ASC),
    CONSTRAINT [FK_MediaIrisCompetitrackAppMap_MobileApp] FOREIGN KEY ([MobileAppID]) REFERENCES [dbo].[MobileApp] ([MobileAppID])
);

