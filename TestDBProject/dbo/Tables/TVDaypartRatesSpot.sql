﻿CREATE TABLE [dbo].[TVDaypartRatesSpot] (
    [TVDaypartRatesSpotID] INT          IDENTITY (1, 1) NOT NULL,
    [TVStationID]          INT          NOT NULL,
    [TVDaypartTimeZoneId]  INT          NOT NULL,
    [Rate]                 NUMERIC (18) NOT NULL,
    [EffectiveStartDate]   DATE         NOT NULL,
    [EffectiveEndDate]     DATE         NULL,
    [ModifyDT]             DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([TVDaypartRatesSpotID] ASC),
    CONSTRAINT [FK_TVDaypartRatesSpot_To_DaypartTimeZone] FOREIGN KEY ([TVDaypartTimeZoneId]) REFERENCES [dbo].[TVDaypartTimeZone] ([TVDaypartTimeZoneID]),
    CONSTRAINT [FK_TVDaypartRatesSpot_To_TVStation] FOREIGN KEY ([TVStationID]) REFERENCES [dbo].[TVStation] ([TVStationID])
);

