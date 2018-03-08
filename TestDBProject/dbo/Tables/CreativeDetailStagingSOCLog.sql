CREATE TABLE [dbo].[CreativeDetailStagingSOCLog] (
    [LogTimeStamp]               DATETIME      NULL,
    [LogDMLOperation]            CHAR (1)      NULL,
    [LoginUser]                  VARCHAR (32)  NULL,
    [CreativeDetailSOCStagingID] INT           NULL,
    [CreativeStagingMasterID]    INT           NULL,
    [CreativeFileType]           VARCHAR (MAX) NULL,
    [CreativeRepository]         VARCHAR (MAX) NULL,
    [CreativeAssetName]          VARCHAR (MAX) NULL,
    [CreativeFileSize]           DECIMAL (18)  NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

