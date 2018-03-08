CREATE TABLE [dbo].[NLSNProgramScheduleTemp] (
    [NLSNProgramScheduleTempID] INT           IDENTITY (1, 1) NOT NULL,
    [MarketID]                  VARCHAR (50)  NOT NULL,
    [Channel]                   VARCHAR (50)  NOT NULL,
    [AirDate]                   VARCHAR (50)  NOT NULL,
    [ProgramName]               VARCHAR (250) NOT NULL,
    [StartTime]                 VARCHAR (50)  NOT NULL,
    [EndTime]                   VARCHAR (50)  NOT NULL,
    [QuarterHourID]             INT           NOT NULL,
    [CreatedDT]                 DATETIME      NOT NULL,
    [CreatedByID]               INT           NOT NULL,
    [ModifiedDT]                DATETIME      NULL,
    [ModifiedByID]              INT           NULL
);

