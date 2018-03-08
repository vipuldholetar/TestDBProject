CREATE TABLE [dbo].[NLSNSpotProgramSchedule] (
    [NLSNSpotProgramScheduleID] INT          IDENTITY (1, 1) NOT NULL,
    [ProgramName]               VARCHAR (50) NOT NULL,
    [ProgramSource]             VARCHAR (50) NOT NULL,
    [NLSNMarketCode]            VARCHAR (50) NULL,
    [MarketID]                  INT          NOT NULL,
    [NLSNStationID]             VARCHAR (50) NOT NULL,
    [TVStationID]               INT          NULL,
    [AirDT]                     DATETIME     NOT NULL,
    [QuarterHourID]             INT          NOT NULL,
    [ProgramStartTime]          TIME (7)     NOT NULL,
    [ProgramEndTime]            TIME (7)     NOT NULL,
    [NLSNStartTime]             TIME (7)     NOT NULL,
    [NLSNEndTime]               TIME (7)     NOT NULL,
    [CreatedDT]                 DATETIME     NOT NULL,
    [CreatedByID]               INT          NOT NULL,
    [ModifiedDT]                DATETIME     NULL,
    [ModifiedByID]              INT          NULL,
    CONSTRAINT [PK_NLSNSpotProgramSchedule] PRIMARY KEY CLUSTERED ([NLSNSpotProgramScheduleID] ASC)
);

