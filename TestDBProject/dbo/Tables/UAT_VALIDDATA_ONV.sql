﻿CREATE TABLE [dbo].[UAT_VALIDDATA_ONV] (
    [SignatureDefault]        CHAR (40) NOT NULL,
    [CreativeDownloaded]      BIT       NOT NULL,
    [CreativeDetailStagingID] INT       NOT NULL,
    [ScrapeSessionID]         INT       NOT NULL,
    [OccurrenceDetailID]      INT       NOT NULL,
    [PatternMasterStagingID]  INT       NULL,
    [CreativeStgID]           INT       NULL,
    [FileSize]                INT       NOT NULL,
    CONSTRAINT [PK_UAT_VALIDDATA_ONV] PRIMARY KEY CLUSTERED ([CreativeDetailStagingID] ASC, [OccurrenceDetailID] ASC)
);

