CREATE TABLE [dbo].[RefAssetRepositoryLog] (
    [LogTimeStamp]              DATETIME      NULL,
    [LogDMLOperation]           CHAR (1)      NULL,
    [LoginUser]                 VARCHAR (32)  NULL,
    [RefAssetRepositoryID]      INT           NULL,
    [MediaStreamID]             INT           NULL,
    [OldVal_MediaStreamID]      INT           NULL,
    [UserGroup]                 VARCHAR (150) NULL,
    [OldVal_UserGroup]          VARCHAR (150) NULL,
    [AssetSystem]               VARCHAR (150) NULL,
    [OldVal_AssetSystem]        VARCHAR (150) NULL,
    [CreativeRepository]        VARCHAR (250) NULL,
    [OldVal_CreativeRepository] VARCHAR (250) NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

