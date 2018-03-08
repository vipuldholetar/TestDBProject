CREATE TABLE [dbo].[CreativesSentToAWS] (
    [CreativeAWSID]      INT            IDENTITY (1, 1) NOT NULL,
    [MediaType]          NVARCHAR (50)  NULL,
    [AdID]               INT            NULL,
    [CreativeDetailID]   INT            NULL,
    [AwsCreativeKey]     NVARCHAR (200) NULL,
    [AwsThumbnailKey]    NVARCHAR (200) NULL,
    [CreativeDomainCode] NVARCHAR (50)  NULL,
    [CreativeDomainName] NVARCHAR (250) NULL,
    [FileFormat]         NVARCHAR (50)  NULL,
    [MimeType]           NVARCHAR (50)  NULL,
    [ViewType]           NVARCHAR (50)  NULL,
    [PlayerMode]         NVARCHAR (50)  NULL,
    [OrderID]            INT            NULL,
    [OccurrenceID]       INT            NULL,
    [CreativeSignature]  NVARCHAR (200) NULL,
    [transferDT]         DATETIME       NULL,
    CONSTRAINT [PK_CreativesSentToAWS] PRIMARY KEY CLUSTERED ([CreativeAWSID] ASC)
);

