CREATE TABLE [dbo].[TVStations] (
    [TVStationsID]       INT          IDENTITY (1, 1) NOT NULL,
    [MTStationCode]      VARCHAR (20) NOT NULL,
    [NetworkAffiliation] VARCHAR (20) NULL,
    [StationName]        VARCHAR (50) NULL,
    [Cable]              CHAR (5)     NULL,
    [Dma]                VARCHAR (20) NULL,
    [MTEthnicGrpID]      INT          NULL,
    [CreatedDT]          DATETIME     CONSTRAINT [DF_TvStationsMaster_CreateDate] DEFAULT (getdate()) NULL,
    [CreatedByID]        INT          NULL,
    [ModifiedDT]         DATETIME     NULL,
    [ModifiedByID]       INT          NULL,
    CONSTRAINT [PK_TvStationsMaster] PRIMARY KEY CLUSTERED ([TVStationsID] ASC)
);

