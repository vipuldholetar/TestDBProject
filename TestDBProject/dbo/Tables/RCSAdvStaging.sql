CREATE TABLE [dbo].[RCSAdvStaging] (
    [RCSAdvID]          INT          IDENTITY (3179940, 1) NOT NULL,
    [Name]              VARCHAR (50) NOT NULL,
    [RCSSeqForCreation] BIGINT       NOT NULL,
    [CreatedDT]         DATETIME     NOT NULL,
    [CreatedByID]       INT          NOT NULL,
    [RCSSeqForUpdate]   BIGINT       NULL,
    [ModifiedDT]        DATETIME     NULL,
    [ModifiedByID]      INT          NULL,
    [CTLegacyID]        INT          NULL
);

