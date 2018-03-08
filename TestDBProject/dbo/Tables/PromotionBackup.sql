CREATE TABLE [dbo].[PromotionBackup] (
    [PromotionBackupID] INT            IDENTITY (1, 1) NOT NULL,
    [CropID]            INT            NOT NULL,
    [CategoryID]        INT            NOT NULL,
    [AdvertiserID]      INT            NOT NULL,
    [ProductID]         INT            NOT NULL,
    [ProductDescrip]    NVARCHAR (MAX) NULL,
    [AuditType]         NVARCHAR (MAX) NULL,
    [AuditedBy]         NVARCHAR (MAX) NULL,
    [AuditedDT]         DATETIME       NULL,
    [Query]             TINYINT        NULL,
    [CreatedDT]         DATETIME       NOT NULL,
    [CreatedByID]       INT            NOT NULL,
    [ModifiedDT]        DATETIME       NULL,
    [ModifiedByID]      INT            NULL,
    [PromoPrice]        DECIMAL (18)   NULL
);

