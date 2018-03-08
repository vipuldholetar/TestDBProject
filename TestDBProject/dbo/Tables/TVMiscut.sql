CREATE TABLE [dbo].[TVMiscut] (
    [TVMiscutID] INT          IDENTITY (1, 1) NOT NULL,
    [PRCode]     VARCHAR (50) NOT NULL,
    [IndexedBy]  INT          NULL,
    [IndexedOn]  DATETIME     NULL,
    [QCdBy]      INT          NOT NULL,
    [QCdOn]      DATETIME     NOT NULL
);

