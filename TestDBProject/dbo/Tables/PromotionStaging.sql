CREATE TABLE [dbo].[PromotionStaging] (
    [PromotionStagingID]     INT            IDENTITY (1, 1) NOT NULL,
    [CompositeCropStagingID] INT            NOT NULL,
    [PromoID]                INT            NULL,
    [CompositeCropID]        INT            NULL,
    [CategoryID]             INT            NOT NULL,
    [AdvertiserID]           INT            NULL,
    [ProductID]              INT            NULL,
    [ProductDescrip]         NVARCHAR (MAX) NULL,
    [DeletedInd]             TINYINT        NULL,
    [PromoDetailInd]         TINYINT        NULL,
    [LockedByID]             INT            NOT NULL,
    [LockedDT]               DATETIME       NOT NULL,
    CONSTRAINT [PK_PromotionMasterStaging] PRIMARY KEY CLUSTERED ([PromotionStagingID] ASC)
);

