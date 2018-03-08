﻿CREATE TYPE [dbo].[NCMRawData] AS TABLE (
    [NCMFileName]     VARCHAR (200) NOT NULL,
    [DMANetwork]      VARCHAR (200) NOT NULL,
    [CampaignTitle]   VARCHAR (200) NOT NULL,
    [Customer]        VARCHAR (200) NOT NULL,
    [StartDate]       DATETIME      NOT NULL,
    [EndDate]         DATETIME      NOT NULL,
    [Rating]          VARCHAR (200) NOT NULL,
    [Length]          INT           NOT NULL,
    [AdName]          VARCHAR (200) NOT NULL,
    [IngestionStatus] INT           NULL,
    [IngestionDate]   DATETIME      NULL,
    [Priority]        INT           NULL);

