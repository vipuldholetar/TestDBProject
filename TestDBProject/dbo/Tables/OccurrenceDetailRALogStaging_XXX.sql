﻿CREATE TABLE [dbo].[OccurrenceDetailRALogStaging_XXX] (
    [LogTimeStamp]         DATETIME     NULL,
    [LogDMLOperation]      CHAR (1)     NULL,
    [LoginUser]            VARCHAR (32) NULL,
    [OccurrenceDetailRAID] INT          NULL,
    [PatternID]            INT          NULL,
    [OldVal_PatternID]     INT          NULL,
    [AdID]                 VARCHAR (50) NULL,
    [OldVal_AdID]          VARCHAR (50) NULL,
    [RCSAcIdID]            VARCHAR (50) NULL,
    [OldVal_RCSAcIdID]     VARCHAR (50) NULL,
    [AirDT]                DATETIME     NULL,
    [OldVal_AirDT]         DATETIME     NULL,
    [RCSStationID]         INT          NULL,
    [OldVal_RCSStationID]  INT          NULL,
    [LiveRead]             TINYINT      NULL,
    [OldVal_LiveRead]      TINYINT      NULL,
    [RCSSequenceID]        BIGINT       NULL,
    [OldVal_RCSSequenceID] BIGINT       NULL,
    [AirStartDT]           DATETIME     NULL,
    [OldVal_AirStartDT]    DATETIME     NULL,
    [AirEndDT]             DATETIME     NULL,
    [OldVal_AirEndDT]      DATETIME     NULL,
    [Deleted]              TINYINT      NULL,
    [OldVal_Deleted]       TINYINT      NULL,
    [CreatedDT]            DATETIME     NULL,
    [OldVal_CreatedDT]     DATETIME     NULL,
    [CreatedByID]          INT          NULL,
    [OldVal_CreatedByID]   INT          NULL,
    [ModifiedDT]           DATETIME     NULL,
    [OldVal_ModifiedDT]    DATETIME     NULL,
    [ModifiedByID]         INT          NULL,
    [OldVal_ModifiedByID]  INT          NULL,
    [CTLegacySeq]          INT          NULL,
    [OldVal_CTLegacySeq]   INT          NULL
);

