﻿CREATE TABLE [dbo].[ConfigurationReqdStageLog] (
    [LogTimeStamp]        DATETIME     NULL,
    [LogDMLOperation]     CHAR (1)     NULL,
    [LoginUser]           VARCHAR (32) NULL,
    [MTCTBoth]            VARCHAR (2)  NULL,
    [OldVal_MTCTBoth]     VARCHAR (2)  NULL,
    [NewAdInd]            BIT          NULL,
    [MapReqdInd]          BIT          NULL,
    [OldVal_MapReqdInd]   BIT          NULL,
    [IndexReqdInd]        BIT          NULL,
    [OldVal_IndexReqdInd] BIT          NULL,
    [ScanReqdInd]         BIT          NULL,
    [OldVal_ScanReqdInd]  BIT          NULL,
    [QCReqdInd]           BIT          NULL,
    [OldVal_QCReqdInd]    BIT          NULL,
    [RouteReqdInd]        BIT          NULL,
    [OldVal_RouteReqdInd] BIT          NULL,
    [CreatedDT]           DATETIME     NULL,
    [OldVal_CreatedDT]    DATETIME     NULL,
    [CreateByID]          INT          NULL,
    [OldVal_CreateByID]   INT          NULL,
    [ModifiedDT]          DATETIME     NULL,
    [OldVal_ModifiedDT]   DATETIME     NULL,
    [ModifiedByID]        INT          NULL,
    [OldVal_ModifiedByID] INT          NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

