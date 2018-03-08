CREATE TABLE [dbo].[TVCreativeDetailStagingTV_staging] (
    [CreativeDetailStagingTVID] BIGINT        IDENTITY (1, 1) NOT NULL,
    [CreativeStgMasterID]       INT           NOT NULL,
    [OccurrenceID]              BIGINT        NULL,
    [MediaFormat]               CHAR (10)     NOT NULL,
    [MediaFilepath]             VARCHAR (200) NOT NULL,
    [MediaFileName]             VARCHAR (200) NOT NULL,
    [FileSize]                  BIGINT        NOT NULL,
    [CreativeResolution]        VARCHAR (2)   NULL
);

