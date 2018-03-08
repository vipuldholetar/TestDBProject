﻿CREATE TABLE [dbo].[CreativeDetailPUBLog] (
    [LogTimeStamp]                   DATETIME       NULL,
    [LogDMLOperation]                CHAR (1)       NULL,
    [LoginUser]                      VARCHAR (32)   NULL,
    [CreativeDetailID]               INT            NULL,
    [CreativeMasterID]               INT            NULL,
    [OldVal_CreativeMasterID]        INT            NULL,
    [CreativeAssetName]              NVARCHAR (MAX) NULL,
    [OldVal_CreativeAssetName]       NVARCHAR (MAX) NULL,
    [CreativeRepository]             NVARCHAR (MAX) NULL,
    [OldVal_CreativeRepository]      NVARCHAR (MAX) NULL,
    [LegacyCreativeAssetName]        NVARCHAR (MAX) NULL,
    [OldVal_LegacyCreativeAssetName] NVARCHAR (MAX) NULL,
    [CreativeFileType]               NVARCHAR (MAX) NULL,
    [OldVal_CreativeFileType]        NVARCHAR (MAX) NULL,
    [Deleted]                        BIT            NULL,
    [OldVal_Deleted]                 BIT            NULL,
    [PageNumber]                     INT            NULL,
    [OldVal_PageNumber]              INT            NULL,
    [PageTypeID]                     NVARCHAR (50)  NULL,
    [OldVal_PageTypeID]              NVARCHAR (50)  NULL,
    [PixelHeight]                    INT            NULL,
    [OldVal_PixelHeight]             INT            NULL,
    [PixelWidth]                     INT            NULL,
    [OldVal_PixelWidth]              INT            NULL,
    [FK_SizeID]                      INT            NULL,
    [OldVal_FK_SizeID]               INT            NULL,
    [FormName]                       VARCHAR (100)  NULL,
    [OldVal_FormName]                VARCHAR (100)  NULL,
    [PageStartDT]                    DATETIME       NULL,
    [OldVal_PageStartDT]             DATETIME       NULL,
    [PageEndDT]                      DATETIME       NULL,
    [OldVal_PageEndDT]               DATETIME       NULL,
    [PageName]                       VARCHAR (50)   NULL,
    [OldVal_PageName]                VARCHAR (50)   NULL,
    [PubPageNumber]                  INT            NULL,
    [OldVal_PubPageNumber]           INT            NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);
