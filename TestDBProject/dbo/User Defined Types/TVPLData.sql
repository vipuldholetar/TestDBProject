CREATE TYPE [dbo].[TVPLData] AS TABLE (
    [InputFileName]      VARCHAR (200) NOT NULL,
    [CaptureStationCode] VARCHAR (200) NOT NULL,
    [AirDateTime]        DATETIME      NOT NULL,
    [CaptureTime]        DATETIME      NOT NULL,
    [Length]             INT           NOT NULL,
    [PatternCode]        VARCHAR (200) NOT NULL,
    [CreateDTM]          DATETIME      NOT NULL,
    [IngestionDTM]       DATETIME      NULL,
    [IngestionStatus]    INT           NULL,
    [Station]            VARCHAR (10)  NOT NULL);

