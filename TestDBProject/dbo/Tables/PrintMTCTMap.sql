CREATE TABLE [dbo].[PrintMTCTMap] (
    [ExpectationID] INT         NOT NULL,
    [PublicationID] INT         NOT NULL,
    [LanguageID]    INT         NOT NULL,
    [MTCTBoth]      VARCHAR (2) NOT NULL,
    [CreatedDT]     DATETIME    NOT NULL,
    [CreatedByID]   INT         NOT NULL,
    [ModifiedDT]    DATETIME    NULL,
    [ModifiedByID]  INT         NULL,
    CONSTRAINT [PK_PrintCTMTMap] PRIMARY KEY CLUSTERED ([ExpectationID] ASC, [PublicationID] ASC, [LanguageID] ASC)
);

