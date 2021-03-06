﻿CREATE TABLE [dbo].[CreativeDetailEMLog] (
    [LogTimeStamp]              DATETIME      NULL,
    [LogDMLOperation]           CHAR (1)      NULL,
    [LoginUser]                 VARCHAR (32)  NULL,
    [CreativeDetailsEMID]       INT           NULL,
    [CreativeMasterID]          INT           NULL,
    [OldVal_CreativeMasterID]   INT           NULL,
    [CreativeAssetName]         VARCHAR (MAX) NULL,
    [OldVal_CreativeAssetName]  VARCHAR (MAX) NULL,
    [CreativeRepository]        VARCHAR (MAX) NULL,
    [OldVal_CreativeRepository] VARCHAR (MAX) NULL,
    [LegacyAssetName]           VARCHAR (MAX) NULL,
    [OldVal_LegacyAssetName]    VARCHAR (MAX) NULL,
    [CreativeFileType]          VARCHAR (MAX) NULL,
    [OldVal_CreativeFileType]   VARCHAR (MAX) NULL,
    [CreativeFileSize]          INT           NULL,
    [OldVal_CreativeFileSize]   INT           NULL,
    [CreativeFileDate]          DATETIME      NULL,
    [OldVal_CreativeFileDate]   DATETIME      NULL,
    [Deleted]                   BIT           NULL,
    [OldVal_Deleted]            BIT           NULL,
    [PageNumber]                INT           NULL,
    [OldVal_PageNumber]         INT           NULL,
    [PageTypeId]                VARCHAR (50)  NULL,
    [OldVal_PageTypeId]         VARCHAR (50)  NULL,
    [PixelHeight]               INT           NULL,
    [OldVal_PixelHeight]        INT           NULL,
    [PixelWidth]                INT           NULL,
    [OldVal_PixelWidth]         INT           NULL,
    [SizeID]                    INT           NULL,
    [OldVal_SizeID]             INT           NULL,
    [FormName]                  VARCHAR (MAX) NULL,
    [OldVal_FormName]           VARCHAR (MAX) NULL,
    [PageStartDT]               DATETIME      NULL,
    [OldVal_PageStartDT]        DATETIME      NULL,
    [PageEndDT]                 DATETIME      NULL,
    [OldVal_PageEndDT]          DATETIME      NULL,
    [PageName]                  VARCHAR (50)  NULL,
    [OldVal_PageName]           VARCHAR (50)  NULL,
    [EmailPageNumber]           INT           NULL,
    [OldVal_EmailPageNumber]    INT           NULL,
    [CreatedDT]                 DATETIME      NULL,
    [OldVal_CreatedDT]          DATETIME      NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

