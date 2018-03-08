CREATE TABLE [dbo].[TVStationMaster_New] (
    [PK_Id]            INT           IDENTITY (1, 1) NOT NULL,
    [StationShortName] VARCHAR (50)  NOT NULL,
    [EthnicGroupId]    INT           NOT NULL,
    [MarketId]         INT           NOT NULL,
    [NetworkId]        INT           NOT NULL,
    [StationFullName]  VARCHAR (200) NOT NULL,
    [StartDate]        DATETIME      NULL,
    [EndDate]          DATETIME      NULL,
    [CreateDTM]        DATETIME      NOT NULL,
    [CreateBy]         INT           NOT NULL,
    [ModifiedDTM]      DATETIME      NULL,
    [ModifiedBy]       INT           NULL
);

