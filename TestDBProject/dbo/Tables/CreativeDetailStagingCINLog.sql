CREATE TABLE [dbo].[CreativeDetailStagingCINLog] (
    [LogTimeStamp]               DATETIME      NULL,
    [LogDMLOperation]            CHAR (1)      NULL,
    [LoginUser]                  VARCHAR (32)  NULL,
    [CreativeDetailStagingCINID] INT           NULL,
    [CreativeStagingID]          INT           NULL,
    [OldVal_CreativeStagingID]   INT           NULL,
    [CreativeFileType]           CHAR (10)     NULL,
    [OldVal_CreativeFileType]    CHAR (10)     NULL,
    [CreativeRepository]         VARCHAR (200) NULL,
    [OldVal_CreativeRepository]  VARCHAR (200) NULL,
    [CreativeAssetName]          VARCHAR (200) NULL,
    [OldVal_CreativeAssetName]   VARCHAR (200) NULL,
    [CreativeFileSize]           BIGINT        NULL,
    [OldVal_CreativeFileSize]    BIGINT        NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

