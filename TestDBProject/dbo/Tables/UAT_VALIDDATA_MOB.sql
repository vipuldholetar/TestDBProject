CREATE TABLE [dbo].[UAT_VALIDDATA_MOB] (
    [SignatureDefault]        CHAR (40) NOT NULL,
    [CreativeDownloaded]      BIT       NOT NULL,
    [CreativeDetailStagingID] INT       NOT NULL,
    [CaptureSessionID]        INT       NOT NULL,
    [OccurrenceDetailID]      INT       NOT NULL,
    [PatternMasterStagingID]  INT       NULL,
    [CreativeStgID]           INT       NULL,
    [FileSize]                INT       NOT NULL,
    CONSTRAINT [PK_UAT_VALIDDATA_MOB] PRIMARY KEY CLUSTERED ([CreativeDetailStagingID] ASC, [OccurrenceDetailID] ASC)
);

