﻿CREATE TABLE [dbo].[RefCategoryLog] (
    [LogTimeStamp]             DATETIME       NULL,
    [LogDMLOperation]          CHAR (1)       NULL,
    [LoginUser]                VARCHAR (32)   NULL,
    [RefCategoryID]            INT            NULL,
    [CategoryGroupID]          INT            NULL,
    [OldVal_CategoryGroupID]   INT            NULL,
    [KETemplateID]             INT            NULL,
    [OldVal_KETemplateID]      INT            NULL,
    [CategoryName]             VARCHAR (50)   NULL,
    [OldVal_CategoryName]      VARCHAR (50)   NULL,
    [CategoryShortName]        VARCHAR (50)   NULL,
    [OldVal_CategoryShortName] VARCHAR (50)   NULL,
    [CreateDT]                 DATETIME       NULL,
    [OldVal_CreateDT]          DATETIME       NULL,
    [CreatedByID]              INT            NULL,
    [OldVal_CreatedByID]       INT            NULL,
    [ModifiedDT]               DATETIME       NULL,
    [OldVal_ModifiedDT]        DATETIME       NULL,
    [ModifiedByID]             INT            NULL,
    [OldVal_ModifiedByID]      INT            NULL,
    [EndDT]                    DATETIME       NULL,
    [OldVal_EndDT]             DATETIME       NULL,
    [CTLegacyPCATCODE]         VARCHAR (10)   NULL,
    [OldVal_CTLegacyPCATCODE]  VARCHAR (10)   NULL,
    [CTLegacyPSUPCODE]         VARCHAR (10)   NULL,
    [OldVal_CTLegacyPSUPCODE]  VARCHAR (10)   NULL,
    [CTLegacyPSUPNAME]         VARCHAR (50)   NULL,
    [OldVal_CTLegacyPSUPNAME]  VARCHAR (50)   NULL,
    [Definition1]              VARCHAR (1000) NULL,
    [Definition2]              VARCHAR (1000) NULL,
    [OldVal_Definition1]       VARCHAR (1000) NULL,
    [OldVal_Definition2]       VARCHAR (1000) NULL,
    [RetiredByID]              INT            NULL,
    [OldVal_RetiredByID]       INT            NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);
