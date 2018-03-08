﻿CREATE TABLE [dbo].[RefIndustryGroupLog] (
    [LogTimeStamp]                 DATETIME     NULL,
    [LogDMLOperation]              CHAR (1)     NULL,
    [LoginUser]                    VARCHAR (32) NULL,
    [RefIndustryGroupID]           INT          NULL,
    [ClassificationGroupID]        INT          NULL,
    [OldVal_ClassificationGroupID] INT          NULL,
    [CTLegacyIGRPCODE]             VARCHAR (50) NULL,
    [OldVal_CTLegacyIGRPCODE]      VARCHAR (50) NULL,
    [IndustryCode]                 VARCHAR (50) NULL,
    [OldVal_IndustryCode]          VARCHAR (50) NULL,
    [IndustryName]                 VARCHAR (50) NULL,
    [OldVal_IndustryName]          VARCHAR (50) NULL,
    [Definition]                   VARCHAR (50) NULL,
    [OldVal_Definition]            VARCHAR (50) NULL,
    [CreatedDT]                    DATETIME     NULL,
    [OldVal_CreatedDT]             DATETIME     NULL,
    [CreatedByID]                  INT          NULL,
    [OldVal_CreatedByID]           INT          NULL,
    [ModifedDT]                    DATETIME     NULL,
    [OldVal_ModifedDT]             DATETIME     NULL,
    [ModifiedByID]                 INT          NULL,
    [OldVal_ModifiedByID]          INT          NULL,
    [MultiMapInd]                  BIT          NULL,
    [OldVal_MultiMapInd]           BIT          NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);
