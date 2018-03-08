CREATE TABLE [dbo].[CreativeDetailODRLog] (
    [LogTimeStamp]                   DATETIME      NULL,
    [LogDMLOperation]                CHAR (1)      NULL,
    [LoginUser]                      VARCHAR (32)  NULL,
    [CreativeDetailODRID]            INT           NULL,
    [CreativeMasterID]               INT           NULL,
    [OldVal_CreativeMasterID]        INT           NULL,
    [CreativeAssetName]              VARCHAR (MAX) NULL,
    [OldVal_CreativeAssetName]       VARCHAR (MAX) NULL,
    [CreativeRepository]             VARCHAR (MAX) NULL,
    [OldVal_CreativeRepository]      VARCHAR (MAX) NULL,
    [LegacyCreativeAssetName]        VARCHAR (MAX) NULL,
    [OldVal_LegacyCreativeAssetName] VARCHAR (MAX) NULL,
    [CreativeFileType]               VARCHAR (MAX) NULL,
    [OldVal_CreativeFileType]        VARCHAR (MAX) NULL,
    [CreatedDT]                      DATETIME      NULL,
    [OldVal_CreatedDT]               DATETIME      NULL,
    [AdFormatID]                     INT           NULL,
    [OldVal_AdFormatId]              INT           NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

