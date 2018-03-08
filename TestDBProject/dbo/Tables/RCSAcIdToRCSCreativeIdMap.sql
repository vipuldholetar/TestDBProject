CREATE TABLE [dbo].[RCSAcIdToRCSCreativeIdMap] (
    [RCSAcIdToRCSCreativeIdMapID] INT          NOT NULL,
    [RCSCreativeID]               VARCHAR (50) NULL,
    [Deleted]                     INT          NOT NULL,
    [RCSInitialSeq]               BIGINT       NULL,
    [CreatedDT]                   DATETIME     DEFAULT (getdate()) NOT NULL,
    [CreatedByID]                 INT          NOT NULL,
    [RCSUpdateSeq]                BIGINT       NULL,
    [ModifiedDT]                  DATETIME     NULL,
    [ModifiedByID]                INT          NULL,
    [CTLegacyID]                  INT          NULL,
    CONSTRAINT [PK_RCSAcIdToRCSCreativeIdMap_1] PRIMARY KEY CLUSTERED ([RCSAcIdToRCSCreativeIdMapID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_RCSAcIdToRCSCreativeIdMap_RCSCreativeId]
    ON [dbo].[RCSAcIdToRCSCreativeIdMap]([RCSCreativeID] ASC);

