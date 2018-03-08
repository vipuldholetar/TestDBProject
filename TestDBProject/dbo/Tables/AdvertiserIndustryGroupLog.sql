﻿CREATE TABLE [dbo].[AdvertiserIndustryGroupLog] (
    [LogTimeStamp]              DATETIME     NULL,
    [LogDMLOperation]           CHAR (1)     NULL,
    [LoginUser]                 VARCHAR (32) NULL,
    [AdvertiserIndustryGroupID] INT          NULL,
    [AdvertiserID]              INT          NULL,
    [OldVal_AdvertiserID]       INT          NULL,
    [IndustryGroupID]           INT          NULL,
    [OldVal_IndustryGroupID]    INT          NULL,
    [CreatedDT]                 DATETIME     NULL,
    [OldVal_CreatedDT]          DATETIME     NULL,
    [CreatedByID]               INT          NULL,
    [OldVal_CreatedByID]        INT          NULL,
    [ModifiedDT]                DATETIME     NULL,
    [OldVal_ModifiedDT]         DATETIME     NULL,
    [ModifiedByID]              INT          NULL,
    [OldVal_ModifiedByID]       INT          NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

