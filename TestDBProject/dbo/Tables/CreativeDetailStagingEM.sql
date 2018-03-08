CREATE TABLE [dbo].[CreativeDetailStagingEM] (
    [CreativeDetailStagingEMID] INT           IDENTITY (1, 1) NOT NULL,
    [CreativeStagingID]         INT           NOT NULL,
    [CreativeAssetName]         VARCHAR (MAX) NULL,
    [CreativeRepository]        VARCHAR (MAX) NULL,
    [LegacyAssetName]           VARCHAR (MAX) NULL,
    [CreativeFileType]          VARCHAR (MAX) NULL,
    [CreativeFileSize]          INT           NULL,
    [CreativeFileDate]          DATETIME      NULL,
    [Deleted]                   BIT           NULL,
    [PageNumber]                INT           NULL,
    [PageTypeId]                VARCHAR (50)  NULL,
    [PixelHeight]               INT           NULL,
    [PixelWidth]                INT           NULL,
    [SizeID]                    INT           NULL,
    [FormName]                  VARCHAR (MAX) NULL,
    [PageStartDT]               DATETIME      NULL,
    [PageEndDT]                 DATETIME      NULL,
    [PageName]                  VARCHAR (50)  NULL,
    [EmailPageNumber]           INT           NULL,
    CONSTRAINT [PK_CreativeDetailStagingEM] PRIMARY KEY CLUSTERED ([CreativeDetailStagingEMID] ASC)
);

