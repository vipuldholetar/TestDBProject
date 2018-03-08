﻿CREATE TABLE [dbo].[CreativeDetailWebLog] (
    [LogTimeStamp]              DATETIME       NULL,
    [LogDMLOperation]           CHAR (1)       NULL,
    [LoginUser]                 VARCHAR (32)   NULL,
    [CreativeDetailWebID]       INT            NULL,
    [CreativeMasterID]          INT            NULL,
    [OldVal_CreativeMasterID]   INT            NULL,
    [CreativeAssetName]         NVARCHAR (MAX) NULL,
    [OldVal_CreativeAssetName]  NVARCHAR (MAX) NULL,
    [CreativeRepository]        NVARCHAR (MAX) NULL,
    [OldVal_CreativeRepository] NVARCHAR (MAX) NULL,
    [LegacyAssetName]           NVARCHAR (MAX) NULL,
    [OldVal_LegacyAssetName]    NVARCHAR (MAX) NULL,
    [CreativeFileType]          NVARCHAR (MAX) NULL,
    [OldVal_CreativeFileType]   NVARCHAR (MAX) NULL,
    [CreativeFileSize]          INT            NULL,
    [OldVal_CreativeFileSize]   INT            NULL,
    [CreativeFileDate]          DATETIME       NULL,
    [OldVal_CreativeFileDate]   DATETIME       NULL,
    [Deleted]                   BIT            NULL,
    [OldVal_Deleted]            BIT            NULL,
    [PageNumber]                INT            NULL,
    [OldVal_PageNumber]         INT            NULL,
    [PageTypeID]                NVARCHAR (50)  NULL,
    [OldVal_PageTypeID]         NVARCHAR (50)  NULL,
    [PixelHeight]               INT            NULL,
    [OldVal_PixelHeight]        INT            NULL,
    [PixelWidth]                INT            NULL,
    [OldVal_PixelWidth]         INT            NULL,
    [SizeID]                    INT            NULL,
    [OldVal_SizeID]             INT            NULL,
    [FormName]                  NVARCHAR (MAX) NULL,
    [OldVal_FormName]           NVARCHAR (MAX) NULL,
    [PageStartDT]               DATETIME       NULL,
    [OldVal_PageStartDT]        DATETIME       NULL,
    [PageEndDT]                 DATETIME       NULL,
    [OldVal_PageEndDT]          DATETIME       NULL,
    [PageName]                  NVARCHAR (50)  NULL,
    [OldVal_PageName]           NVARCHAR (50)  NULL,
    [PubPageNumber]             INT            NULL,
    [OldVal_PubPageNumber]      INT            NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);
