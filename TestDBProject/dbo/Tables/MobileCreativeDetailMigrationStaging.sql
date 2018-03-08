CREATE TABLE [dbo].[MobileCreativeDetailMigrationStaging] (
    [CreativeDetailMOBID] INT            IDENTITY (1, 1) NOT NULL,
    [CreativeMasterID]    INT            NOT NULL,
    [CreativeAssetName]   NVARCHAR (MAX) NULL,
    [CreativeRepository]  NVARCHAR (MAX) NULL,
    [LegacyAssetName]     NVARCHAR (MAX) NULL,
    [CreativeFileType]    NVARCHAR (MAX) NULL,
    [CreativeFileSize]    INT            NULL,
    [CreativeFileDT]      DATETIME       NULL
);

