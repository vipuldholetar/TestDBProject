CREATE TABLE [dbo].[CreativeDetailMOBLog] (
    [LogTimeStamp]              DATETIME       NULL,
    [LogDMLOperation]           CHAR (1)       NULL,
    [LoginUser]                 VARCHAR (32)   NULL,
    [CreativeDetailMOBID]       INT            NULL,
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
    [CreativeFileDT]            DATETIME       NULL,
    [OldVal_CreativeFileDT]     DATETIME       NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

