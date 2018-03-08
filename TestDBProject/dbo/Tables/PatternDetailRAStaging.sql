CREATE TABLE [dbo].[PatternDetailRAStaging] (
    [PatternDetailRAStagingID] INT          IDENTITY (1, 1) NOT NULL,
    [PatternStgID]             INT          NOT NULL,
    [RCSCreativeID]            VARCHAR (50) NOT NULL,
    [CreatedDT]                DATETIME     NULL,
    [CreatedByID]              INT          NULL,
    [ModifiedDT]               DATETIME     NULL,
    [ModifiedByID]             INT          NULL,
    CONSTRAINT [PK_PatternDetailRAStg] PRIMARY KEY CLUSTERED ([PatternDetailRAStagingID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_PatternDetailRAStaging_RCSCreativeID]
    ON [dbo].[PatternDetailRAStaging]([RCSCreativeID] ASC)
    INCLUDE([PatternStgID]);

