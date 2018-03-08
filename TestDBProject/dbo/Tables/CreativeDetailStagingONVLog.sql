﻿CREATE TABLE [dbo].[CreativeDetailStagingONVLog] (
    [LogTimeStamp]                 DATETIME       NULL,
    [LogDMLOperation]              CHAR (1)       NULL,
    [LoginUser]                    VARCHAR (32)   NULL,
    [CreativeDetailStagingID]      INT            NULL,
    [CreativeStagingID]            INT            NULL,
    [OldVal_CreativeStagingID]     INT            NULL,
    [SourceUrlID]                  INT            NULL,
    [OldVal_SourceUrlID]           INT            NULL,
    [MediaIrisCreativeID]          INT            NULL,
    [OldVal_MediaIrisCreativeID]   INT            NULL,
    [CreativeFileType]             VARCHAR (10)   NULL,
    [OldVal_CreativeFileType]      VARCHAR (10)   NULL,
    [CreativeDownloaded]           BIT            NULL,
    [OldVal_CreativeDownloaded]    BIT            NULL,
    [LandingPageDownloaded]        BIT            NULL,
    [OldVal_LandingPageDownloaded] BIT            NULL,
    [CreativeRepository]           VARCHAR (1000) NULL,
    [OldVal_CreativeRepository]    VARCHAR (1000) NULL,
    [CreativeAssetName]            VARCHAR (255)  NULL,
    [OldVal_CreativeAssetName]     VARCHAR (255)  NULL,
    [FileSize]                     INT            NULL,
    [OldVal_FileSize]              INT            NULL,
    [Duration]                     INT            NULL,
    [OldVal_Duration]              INT            NULL,
    [SignatureDefault]             CHAR (40)      NULL,
    [OldVal_SignatureDefault]      CHAR (40)      NULL,
    [SignatureMPG]                 CHAR (40)      NULL,
    [OldVal_SignatureMPG]          CHAR (40)      NULL,
    [CreatedDT]                    DATETIME       NULL,
    [OldVal_CreatedDT]             DATETIME       NULL,
    [ModifiedDT]                   DATETIME       NULL,
    [OldVal_ModifiedDT]            DATETIME       NULL,
    [Height]                       INT            NULL,
    [OldVal_Height]                INT            NULL,
    [Width]                        INT            NULL,
    [OldVal_Width]                 INT            NULL,
    [MediaFileName]                VARCHAR (500)  NULL,
    [OldVal_MediaFileName]         VARCHAR (500)  NULL,
    [MediaIrisAssetName]           VARCHAR (100)  NULL,
    [OldVal_MediaIrisAssetName]    VARCHAR (100)  NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

