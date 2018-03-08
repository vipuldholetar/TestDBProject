CREATE TABLE [dbo].[PromotionDetail] (
    [PromotionDetailID] INT            IDENTITY (1, 1) NOT NULL,
    [PromotionID]       INT            NOT NULL,
    [KeyElementID]      INT            NOT NULL,
    [AnsVarchar]        NVARCHAR (MAX) NULL,
    [AnsMemo]           NVARCHAR (MAX) NULL,
    [AnsNumeric]        DECIMAL (18)   NULL,
    [AnsTimestamp]      DATETIME       NULL,
    [AnsBoolean]        TINYINT        NULL,
    [AnsConfigValue]    NVARCHAR (MAX) NULL,
    [CreatedDT]         DATETIME       NOT NULL,
    [CreatedByID]       INT            NOT NULL,
    [ModifiedDT]        DATETIME       NULL,
    [ModifiedByID]      INT            NULL,
    CONSTRAINT [PK_PromotionDetail] PRIMARY KEY CLUSTERED ([PromotionDetailID] ASC)
);

