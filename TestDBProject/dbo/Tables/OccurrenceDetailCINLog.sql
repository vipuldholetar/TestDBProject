﻿CREATE TABLE [dbo].[OccurrenceDetailCINLog] (
    [LogTimeStamp]          DATETIME      NULL,
    [LogDMLOperation]       CHAR (1)      NULL,
    [LoginUser]             VARCHAR (32)  NULL,
    [OccurrenceDetailCINID] BIGINT        NULL,
    [PatternID]             INT           NULL,
    [OldVal_PatternID]      INT           NULL,
    [AdID]                  INT           NULL,
    [OldVal_AdID]           INT           NULL,
    [MarketID]              INT           NULL,
    [OldVal_MarketID]       INT           NULL,
    [WorkType]              INT           NULL,
    [OldVal_WorkType]       INT           NULL,
    [CreativeID]            VARCHAR (200) NULL,
    [OldVal_CreativeID]     VARCHAR (200) NULL,
    [AirDT]                 DATETIME      NULL,
    [OldVal_AirDT]          DATETIME      NULL,
    [Customer]              VARCHAR (200) NULL,
    [OldVal_Customer]       VARCHAR (200) NULL,
    [Rating]                VARCHAR (200) NULL,
    [OldVal_Rating]         VARCHAR (200) NULL,
    [Length]                INT           NULL,
    [OldVal_Length]         INT           NULL,
    [CreatedDT]             DATETIME      NULL,
    [OldVal_CreatedDT]      DATETIME      NULL,
    [ModifiedDT]            DATETIME      NULL,
    [OldVal_ModifiedDT]     DATETIME      NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

