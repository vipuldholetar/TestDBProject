﻿CREATE TABLE [dbo].[TVStationLog] (
    [LogTimeStamp]            DATETIME      NULL,
    [LogDMLOperation]         CHAR (1)      NULL,
    [LoginUser]               VARCHAR (32)  NULL,
    [TVStationID]             INT           NULL,
    [StationShortName]        VARCHAR (4)   NULL,
    [OldVal_StationShortName] VARCHAR (4)   NULL,
    [EthnicGroupId]           INT           NULL,
    [OldVal_EthnicGroupId]    INT           NULL,
    [MarketID]                INT           NULL,
    [OldVal_MarketID]         INT           NULL,
    [NetworkID]               INT           NULL,
    [OldVal_NetworkID]        INT           NULL,
    [StationFullName]         VARCHAR (200) NULL,
    [OldVal_StationFullName]  VARCHAR (200) NULL,
    [StartDT]                 DATETIME      NULL,
    [OldVal_StartDT]          DATETIME      NULL,
    [EndDT]                   DATETIME      NULL,
    [OldVal_EndDT]            DATETIME      NULL,
    [CreatedDT]               DATETIME      NULL,
    [OldVal_CreatedDT]        DATETIME      NULL,
    [CreatedByID]             INT           NULL,
    [OldVal_CreatedByID]      INT           NULL,
    [ModifiedDT]              DATETIME      NULL,
    [OldVal_ModifiedDT]       DATETIME      NULL,
    [ModifiedByID]            INT           NULL,
    [OldVal_ModifiedByID]     INT           NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

