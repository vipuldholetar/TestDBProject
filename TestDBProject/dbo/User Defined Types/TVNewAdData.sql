CREATE TYPE [dbo].[TVNewAdData] AS TABLE (
    [InputFileName]   VARCHAR (200) NOT NULL,
    [PatternCode]     VARCHAR (200) NOT NULL,
    [Length]          INT           NOT NULL,
    [Priority]        INT           NOT NULL,
    [CreateDTM]       DATETIME      NOT NULL,
    [IngestionDTM]    DATETIME      NULL,
    [IngestionStatus] INT           NULL,
    [Station]         VARCHAR (4)   NULL);

