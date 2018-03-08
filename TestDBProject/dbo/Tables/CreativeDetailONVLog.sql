CREATE TABLE [dbo].[CreativeDetailONVLog] (
    [LogTimeStamp]              DATETIME      NULL,
    [LogDMLOperation]           CHAR (1)      NULL,
    [LoginUser]                 VARCHAR (32)  NULL,
    [CreativeDetailONVID]       INT           NULL,
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
    [CreativeFileDT]            DATETIME      NULL,
    [OldVal_CreativeFileDT]     DATETIME      NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

