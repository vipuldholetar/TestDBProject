CREATE TABLE [dbo].[PatternDetailTVStaging] (
    [PatternDetailTVStagingID] BIGINT IDENTITY (1, 1) NOT NULL,
    [PatternStagingID]         INT    NOT NULL,
    CONSTRAINT [PK_PatternDetailsTVStaging] PRIMARY KEY CLUSTERED ([PatternDetailTVStagingID] ASC)
);

