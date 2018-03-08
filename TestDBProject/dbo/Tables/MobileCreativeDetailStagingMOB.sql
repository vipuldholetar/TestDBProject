CREATE TABLE [dbo].[MobileCreativeDetailStagingMOB] (
    [CreativeDetailStagingID] INT            IDENTITY (1, 1) NOT NULL,
    [CreativeStagingID]       INT            NOT NULL,
    [MediaIrisCreativeID]     INT            NOT NULL,
    [CreativeFileType]        VARCHAR (20)   NULL,
    [CreativeDownloaded]      BIT            NOT NULL,
    [LandingPageDownloaded]   BIT            NOT NULL,
    [CreativeRepository]      VARCHAR (1000) NULL,
    [CreativeAssetName]       VARCHAR (255)  NOT NULL,
    [FileSize]                INT            NOT NULL,
    [Duration]                INT            NULL,
    [SignatureDefault]        CHAR (40)      NOT NULL,
    [SignatureMPG]            CHAR (40)      NULL,
    [CreatedDT]               DATETIME       NOT NULL,
    [ModifiedDT]              DATETIME       NULL,
    [SourceUrlID]             INT            NOT NULL,
    [Height]                  INT            NULL,
    [Width]                   INT            NULL,
    [MediaFileName]           VARCHAR (500)  NULL
);

