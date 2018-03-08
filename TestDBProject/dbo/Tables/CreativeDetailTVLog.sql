CREATE TABLE [dbo].[CreativeDetailTVLog] (
    [LogTimeStamp]                   DATETIME       NULL,
    [LogDMLOperation]                CHAR (1)       NULL,
    [LoginUser]                      VARCHAR (32)   NULL,
    [CreativeDetailTVID]             INT            NULL,
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
    [CreativeResolution]             VARCHAR (2)    NULL,
    [OldVal_CreativeResolution]      VARCHAR (2)    NULL,
    [CreatedDT]                      DATETIME       NULL,
    [OldVal_CreatedDT]               DATETIME       NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

