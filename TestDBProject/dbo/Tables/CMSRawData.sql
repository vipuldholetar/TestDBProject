CREATE TABLE [dbo].[CMSRawData] (
    [CMSRawDataID]        BIGINT        IDENTITY (1, 1) NOT NULL,
    [CMSFileName]         VARCHAR (200) NOT NULL,
    [CMSFileSize]         INT           NOT NULL,
    [CMSFileDate]         DATETIME      NOT NULL,
    [CMSSourceFolder]     VARCHAR (200) NOT NULL,
    [CMSAdvertiser]       VARCHAR (200) NULL,
    [CMSMarket]           VARCHAR (200) NULL,
    [CMSFormat]           VARCHAR (200) NULL,
    [CMSLocation]         VARCHAR (200) NULL,
    [CMSDatePictureTaken] DATETIME      NULL,
    [IngestionStatus]     VARCHAR (50)  NULL,
    [IngestionDT]         DATETIME      NULL,
    CONSTRAINT [PK_CMSRawData] PRIMARY KEY CLUSTERED ([CMSRawDataID] ASC)
);

