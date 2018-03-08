CREATE TABLE [dbo].[TMSTvStation] (
    [TMSTvStationID] INT           IDENTITY (1, 1) NOT NULL,
    [TvStationName]  VARCHAR (100) NOT NULL,
    [AltStationID]   INT           NULL,
    [CreatedDT]      DATETIME      NULL,
    [CreatedByID]    INT           NULL,
    [ModifiedDT]     DATETIME      NULL,
    [ModifiedByID]   INT           NULL,
    CONSTRAINT [PK_TMSTvStationMaster] PRIMARY KEY CLUSTERED ([TMSTvStationID] ASC)
);

