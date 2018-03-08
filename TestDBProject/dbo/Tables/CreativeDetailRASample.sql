CREATE TABLE [dbo].[CreativeDetailRASample] (
    [CreativeDetailID]        INT             IDENTITY (1, 1) NOT NULL,
    [CreativeMasterID]        INT             NOT NULL,
    [CreativeAssetName]       NVARCHAR (MAX)  NULL,
    [CreativeRepository]      NVARCHAR (MAX)  NULL,
    [LegacyCreativeAssetName] NVARCHAR (MAX)  NULL,
    [CreativeFileType]        NVARCHAR (MAX)  NULL,
    [AudioTranscription]      VARBINARY (MAX) NULL
);

