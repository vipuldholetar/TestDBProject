CREATE TABLE [dbo].[PromotionalDetailStaging] (
    [PromoStagingID]   INT            NOT NULL,
    [PromoDetailID]    INT            NOT NULL,
    [KeyElementID]     INT            NOT NULL,
    [KeyElementName]   NVARCHAR (MAX) NULL,
    [AnsVarchar]       NVARCHAR (MAX) NULL,
    [AnsMemo]          NVARCHAR (MAX) NULL,
    [AnsNumeric]       DECIMAL (18)   NULL,
    [AnsTimestamp]     DATETIME       NULL,
    [AnsBoolean]       TINYINT        NULL,
    [AnsConfigValue]   NVARCHAR (MAX) NULL,
    [KElementDataType] NVARCHAR (MAX) NULL,
    [MaskFormat]       NVARCHAR (MAX) NULL,
    [MultiInd]         CHAR (2)       NULL,
    [ReqdInd]          CHAR (2)       NULL,
    [DefaultValue]     NVARCHAR (MAX) NULL,
    [GroupCODE]        NVARCHAR (MAX) NULL,
    [DisplayOrder]     INT            NULL,
    [SystemName]       NVARCHAR (MAX) NULL,
    [ModuleName]       NVARCHAR (MAX) NULL
);

