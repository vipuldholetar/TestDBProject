CREATE TABLE [dbo].[NLSNProgramSchedule] (
    [NLSNProgramScheduleID] INT           IDENTITY (1, 1) NOT NULL,
    [MarketID]              VARCHAR (50)  NOT NULL,
    [Channel]               VARCHAR (50)  NOT NULL,
    [AirDT]                 DATETIME      NOT NULL,
    [ProgramName]           VARCHAR (250) NOT NULL,
    [StartTime]             TIME (7)      NOT NULL,
    [EndTime]               TIME (7)      NOT NULL,
    [QuarterHourID]         INT           NOT NULL,
    [CreatedDT]             DATETIME      NOT NULL,
    [CreatedByID]           INT           NOT NULL,
    [ModifiedDT]            DATETIME      NULL,
    [ModifiedByID]          INT           NULL,
    CONSTRAINT [PK_NLSNProgramSchedule] PRIMARY KEY CLUSTERED ([NLSNProgramScheduleID] ASC)
);

