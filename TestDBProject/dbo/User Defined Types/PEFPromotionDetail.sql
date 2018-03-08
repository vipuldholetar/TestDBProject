CREATE TYPE [dbo].[PEFPromotionDetail] AS TABLE (
    [FK_KeyElementID] INT            NOT NULL,
    [AnsVarchar]      NVARCHAR (MAX) NULL,
    [AnsMemo]         NVARCHAR (MAX) NULL,
    [AnsNumeric]      DECIMAL (18)   NULL,
    [AnsTimestamp]    DATETIME       NULL,
    [AnsBoolean]      BIT            NULL,
    [AnsConfigValue]  NVARCHAR (MAX) NULL,
    [CreateDate]      DATETIME       NOT NULL,
    [CreateBy]        INT            NOT NULL);

