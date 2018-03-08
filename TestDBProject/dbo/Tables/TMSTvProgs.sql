CREATE TABLE [dbo].[TMSTvProgs] (
    [TMSTvProgsID]        INT      IDENTITY (1, 1) NOT NULL,
    [ProgID]              INT      NOT NULL,
    [ProgTvStationID]     INT      NULL,
    [ProgIngestionTypeID] INT      NULL,
    [ProgEthnicGrpID]     INT      NULL,
    [ProgBroadcastType]   CHAR (1) NULL,
    [CreatedDT]           DATETIME NULL,
    CONSTRAINT [PK_TMSTvProgsMaster] PRIMARY KEY CLUSTERED ([TMSTvProgsID] ASC)
);

