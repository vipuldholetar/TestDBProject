CREATE TABLE [dbo].[RCSCreativeMigrationStaging] (
    [RCSCreativeID]     VARCHAR (50) NOT NULL,
    [RCSAcctID]         INT          NOT NULL,
    [RCSAdvID]          INT          NOT NULL,
    [RCSClassID]        INT          NOT NULL,
    [Priority]          INT          NULL,
    [Deleted]           TINYINT      NOT NULL,
    [RCSSeqForCreation] BIGINT       NOT NULL,
    [CreatedDT]         DATETIME     NOT NULL,
    [CreatedByID]       INT          NOT NULL,
    [RCSSeqForUpdate]   BIGINT       NULL,
    [ModifiedDT]        DATETIME     NULL,
    [ModifiedByID]      INT          NULL,
    [CTLegacyID]        INT          NULL,
    [CreativeLength]    INT          NULL
);

