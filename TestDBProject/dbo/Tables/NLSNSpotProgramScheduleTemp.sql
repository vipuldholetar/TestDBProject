CREATE TABLE [dbo].[NLSNSpotProgramScheduleTemp] (
    [NLSNSpotProgramScheduleTempID] INT          IDENTITY (1, 1) NOT NULL,
    [ProgramName]                   VARCHAR (50) NOT NULL,
    [ProgramSource]                 VARCHAR (50) NOT NULL,
    [NLSNMarketCode]                VARCHAR (50) NOT NULL,
    [NLSNStationID]                 VARCHAR (50) NOT NULL,
    [AirDT]                         DATETIME     NOT NULL,
    [ProgramStartTime]              TIME (7)     NOT NULL,
    [ProgramEndTime]                TIME (7)     NOT NULL,
    CONSTRAINT [PK_NLSNSpotProgramScheduleTemp] PRIMARY KEY CLUSTERED ([NLSNSpotProgramScheduleTempID] ASC)
);

