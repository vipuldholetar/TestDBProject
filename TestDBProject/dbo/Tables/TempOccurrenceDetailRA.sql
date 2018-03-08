CREATE TABLE [dbo].[TempOccurrenceDetailRA] (
    [OccurrenceDetailRAID] INT          IDENTITY (1, 1) NOT NULL,
    [PatternID]            INT          NULL,
    [AdID]                 VARCHAR (50) NULL,
    [RCSAcIdID]            VARCHAR (50) NOT NULL,
    [AirDT]                DATETIME     NOT NULL,
    [RCSStationID]         INT          NOT NULL,
    [LiveRead]             TINYINT      NULL,
    [RCSSequenceID]        BIGINT       NOT NULL,
    [AirStartDT]           DATETIME     NOT NULL,
    [AirEndDT]             DATETIME     NOT NULL,
    [Deleted]              TINYINT      NOT NULL,
    [CreatedDT]            DATETIME     NOT NULL,
    [CreatedByID]          INT          NOT NULL,
    [ModifiedDT]           DATETIME     NULL,
    [ModifiedByID]         INT          NULL,
    [CTLegacySeq]          INT          NULL,
    [Station]              VARCHAR (10) NULL,
    [Pattern]              VARCHAR (50) NULL
);

