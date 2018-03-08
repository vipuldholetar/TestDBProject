﻿CREATE TABLE [dbo].[MobileAppLog] (
    [LogTimeStamp]               DATETIME       NULL,
    [LogDMLOperation]            CHAR (1)       NULL,
    [LoginUser]                  VARCHAR (32)   NULL,
    [MobileAppID]                INT            NULL,
    [Category]                   VARCHAR (24)   NULL,
    [OldVal_Category]            VARCHAR (24)   NULL,
    [Name]                       VARCHAR (100)  NULL,
    [OldVal_Name]                VARCHAR (100)  NULL,
    [CaptureInstructions]        VARCHAR (1000) NULL,
    [OldVal_CaptureInstructions] VARCHAR (1000) NULL,
    [CodingInstructions]         VARCHAR (1000) NULL,
    [OldVal_CodingInstructions]  VARCHAR (1000) NULL,
    [Active]                     NUMERIC (1)    NULL,
    [OldVal_Active]              NUMERIC (1)    NULL,
    [MarketCODE]                 VARCHAR (4)    NULL,
    [OldVal_MarketCODE]          VARCHAR (4)    NULL,
    [LanguageID]                 INT            NULL,
    [OldVal_LanguageID]          INT            NULL,
    [MediaOutletGenreID]         INT            NULL,
    [OldVal_MediaOutletGenreID]  INT            NULL,
    [CreatedDT]                  DATETIME       NULL,
    [OldVal_CreatedDT]           DATETIME       NULL,
    [CTLegacySeq]                NCHAR (10)     NULL,
    [OldVal_CTLegacySeq]         INT            NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);
