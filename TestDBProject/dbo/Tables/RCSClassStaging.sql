CREATE TABLE [dbo].[RCSClassStaging] (
    [RCSClassID]        INT          IDENTITY (2001082, 1) NOT NULL,
    [Name]              VARCHAR (50) NOT NULL,
    [Deleted]           TINYINT      NOT NULL,
    [RCSSeqForCreation] BIGINT       NOT NULL,
    [CreatedDT]         DATETIME     NOT NULL,
    [CreatedByID]       INT          NOT NULL,
    [RCSSeqForUpdate]   BIGINT       NULL,
    [ModifiedDT]        DATETIME     NULL,
    [ModifiedByID]      INT          NULL,
    [CTLegacyID]        INT          NULL
);

