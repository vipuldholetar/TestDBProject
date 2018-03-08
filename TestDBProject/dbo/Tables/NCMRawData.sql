CREATE TABLE [dbo].[NCMRawData] (
    [NCMRawDataID]    BIGINT        IDENTITY (1, 1) NOT NULL,
    [NCMFileName]     VARCHAR (200) NOT NULL,
    [DMANetwork]      VARCHAR (200) NOT NULL,
    [CampaignTitle]   VARCHAR (200) NOT NULL,
    [Customer]        VARCHAR (200) NOT NULL,
    [StartDT]         DATETIME      NOT NULL,
    [EndDT]           DATETIME      NOT NULL,
    [Rating]          VARCHAR (200) NOT NULL,
    [Length]          INT           NOT NULL,
    [AdName]          VARCHAR (200) NOT NULL,
    [IngestionStatus] INT           NULL,
    [IngestionDT]     DATETIME      NULL,
    [Priority]        INT           NULL,
    CONSTRAINT [PK_NCMRawData] PRIMARY KEY CLUSTERED ([NCMRawDataID] ASC)
);

