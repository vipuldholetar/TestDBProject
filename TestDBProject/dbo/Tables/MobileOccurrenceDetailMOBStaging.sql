CREATE TABLE [dbo].[MobileOccurrenceDetailMOBStaging] (
    [OccurrenceDetailMOBID] INT          IDENTITY (1, 1) NOT NULL,
    [PatternStagingID]      INT          NULL,
    [PatternID]             INT          NULL,
    [CaptureSessionID]      INT          NOT NULL,
    [ScrapePageID]          INT          NULL,
    [LandingPageID]         INT          NULL,
    [AdID]                  INT          NULL,
    [ResultID]              BIGINT       NOT NULL,
    [OccurrenceDT]          DATETIME     NOT NULL,
    [AdType]                INT          NULL,
    [LandingPageType]       INT          NULL,
    [NumLandingPages]       INT          NULL,
    [CreatedDT]             DATETIME     NOT NULL,
    [ModifiedDT]            DATETIME     NULL,
    [CreativeSignature]     VARCHAR (50) NOT NULL,
    [OldPatternID]          INT          NULL
);

