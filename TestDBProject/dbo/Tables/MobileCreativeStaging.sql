CREATE TABLE [dbo].[MobileCreativeStaging] (
    [CreativeStagingID] INT           IDENTITY (1, 1) NOT NULL,
    [AdID]              INT           NULL,
    [Deleted]           BIT           CONSTRAINT [DF_MobCreativeMasterStg_Deleted] DEFAULT ((0)) NOT NULL,
    [Event]             INT           NULL,
    [Theme]             INT           NULL,
    [SaleStartDT]       DATETIME      NULL,
    [SaleEndDT]         DATETIME      NULL,
    [Flash]             BIT           NULL,
    [National]          BIT           NULL,
    [CreatedDT]         DATETIME      CONSTRAINT [DF_MOBCreativeMasterStg_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [DeleteDT]          DATETIME      NULL,
    [OccurrenceID]      INT           NULL,
    [CreativeSignature] VARCHAR (250) NULL,
    [OldID]             INT           NULL
);

