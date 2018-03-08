CREATE TABLE [dbo].[CreativeDetailRALog] (
    [LogTimeStamp]              DATETIME      NULL,
    [LogDMLOperation]           CHAR (1)      NULL,
    [LoginUser]                 VARCHAR (32)  NULL,
    [CreativeDetailRAID]        INT           NULL,
    [CreativeID]                INT           NULL,
    [OldVal_CreativeID]         INT           NULL,
    [AssetName]                 VARCHAR (MAX) NULL,
    [OldVal_AssetName]          VARCHAR (MAX) NULL,
    [CreativeRepository]        VARCHAR (MAX) NULL,
    [OldVal_CreativeRepository] VARCHAR (MAX) NULL,
    [Rep]                       VARCHAR (MAX) NULL,
    [OldVal_Rep]                VARCHAR (MAX) NULL,
    [LegacyAssetName]           VARCHAR (MAX) NULL,
    [OldVal_LegacyAssetName]    VARCHAR (MAX) NULL,
    [FileType]                  VARCHAR (MAX) NULL,
    [OldVal_FileType]           VARCHAR (MAX) NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

