CREATE TABLE [dbo].[MediaIrisCompetitrackWebsiteMap] (
    [WebsiteMapID]      INT           IDENTITY (1, 1) NOT NULL,
    [MediaIrisSiteID]   INT           NOT NULL,
    [WebsiteID]         INT           NOT NULL,
    [UrlFragment]       VARCHAR (100) NOT NULL,
    [EffectiveStartDT]  DATE          NOT NULL,
    [EffectiveEndDT]    DATE          NOT NULL,
    [OnlineDisplayFlag] TINYINT       NOT NULL,
    [OnlineVideoFlag]   TINYINT       NOT NULL,
    [MobileFlag]        TINYINT       NOT NULL,
    [CreatedDT]         DATETIME      CONSTRAINT [DF_MediaIrisCompetitrackWebsiteMap_CreateDTM] DEFAULT (getdate()) NOT NULL,
    [ModifiedDT]        DATETIME      NULL,
    CONSTRAINT [PK_MediaIrisCompetitrackWebsiteMap] PRIMARY KEY CLUSTERED ([WebsiteMapID] ASC)
);

