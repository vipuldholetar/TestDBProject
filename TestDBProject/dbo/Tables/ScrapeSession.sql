CREATE TABLE [dbo].[ScrapeSession] (
    [ScrapeSessionID] INT           IDENTITY (20567608, 1) NOT NULL,
    [WebsiteID]       INT           NOT NULL,
    [ScrapeBeginDT]   DATETIME      NOT NULL,
    [ScrapeEndDT]     DATETIME      NOT NULL,
    [ScrapeDate]      DATE          NOT NULL,
    [RunWeek]         INT           NOT NULL,
    [NodeID]          INT           NOT NULL,
    [JobID]           VARCHAR (25)  NULL,
    [JobSite]         VARCHAR (100) NULL,
    [ProfileName]     VARCHAR (25)  NULL,
    [CreatedDT]       DATETIME      CONSTRAINT [DF_ScrapeSession_CreateDTM] DEFAULT (getdate()) NOT NULL,
    [ModifiedDT]      DATETIME      NULL,
    [MediaStream]     VARCHAR (3)   NULL,
    [CTLegacySeq]     INT           NULL,
    CONSTRAINT [PK_ScrapeSessionONV] PRIMARY KEY CLUSTERED ([ScrapeSessionID] ASC),
    CONSTRAINT [FK_ScrapeSession_MediaIrisCompetitrackNode] FOREIGN KEY ([NodeID]) REFERENCES [dbo].[MediaIrisCompetitrackNode] ([MediaIrisCompetitrackNodeID]),
    CONSTRAINT [FK_ScrapeSession_Website] FOREIGN KEY ([WebsiteID]) REFERENCES [dbo].[Website] ([WebsiteID])
);


GO
CREATE NONCLUSTERED INDEX [IX_ScrapeSession_ScrapeDate]
    ON [dbo].[ScrapeSession]([ScrapeDate] ASC)
    INCLUDE([ScrapeSessionID], [WebsiteID]);


GO
CREATE NONCLUSTERED INDEX [IX_ScrapeSession_SessionId_WebSiteID_BeginScrapeDT]
    ON [dbo].[ScrapeSession]([ScrapeSessionID] ASC, [WebsiteID] ASC, [ScrapeBeginDT] ASC);

