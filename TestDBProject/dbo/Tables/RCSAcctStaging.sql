CREATE TABLE [dbo].[RCSAcctStaging] (
    [RCSAcctID]         INT          IDENTITY (1, 1) NOT NULL,
    [Name]              VARCHAR (50) NOT NULL,
    [AcctMgrID]         VARCHAR (4)  NULL,
    [MostRecentAdvID]   BIGINT       NOT NULL,
    [MostRecentClassID] BIGINT       NULL,
    [Deleted]           TINYINT      NOT NULL,
    [RCSSeqForCreation] BIGINT       NULL,
    [CreatedDT]         DATETIME     NOT NULL,
    [CreatedByID]       INT          NOT NULL,
    [RCSSeqForUpdate]   BIGINT       NULL,
    [ModifiedDT]        DATETIME     NULL,
    [ModifiedByID]      INT          NULL,
    [CTLegacyID]        INT          NULL
);

