CREATE TABLE [dbo].[RadioMigrationOccurrenceStaging] (
    [PatternID]      INT          NULL,
    [AdID]           VARCHAR (50) NULL,
    [RCSAcIdID]      VARCHAR (50) NULL,
    [AirDT]          DATETIME     NULL,
    [RCSStationName] VARCHAR (10) NULL,
    [RCSSequenceID]  BIGINT       NULL,
    [AirStartDT]     DATETIME     NULL,
    [AirEndDT]       DATETIME     NULL,
    [CreatedDT]      DATETIME     NULL,
    [CreatedByID]    INT          NULL,
    [ModifiedDT]     DATETIME     NULL,
    [ModifiedByID]   INT          NULL,
    [CTLegacySeq]    INT          NULL
);

