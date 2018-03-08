CREATE TABLE [dbo].[LandingPageLogStaging_XXX] (
    [LogTimeStamp]      DATETIME       NULL,
    [LogDMLOperation]   CHAR (1)       NULL,
    [LoginUser]         VARCHAR (32)   NULL,
    [LandingPageID]     INT            NULL,
    [LandingURL]        VARCHAR (2000) NULL,
    [OldVal_LandingURL] VARCHAR (2000) NULL,
    [HashURL]           CHAR (30)      NULL,
    [OldVal_HashURL]    CHAR (30)      NULL,
    [CreatedDT]         DATETIME       NULL,
    [OldVal_CreatedDT]  DATETIME       NULL,
    [CTLegacySeq]       INT            NULL,
    [Old_CTLegacySeq]   INT            NULL
);

