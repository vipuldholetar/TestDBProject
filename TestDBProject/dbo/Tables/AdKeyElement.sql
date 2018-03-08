CREATE TABLE [dbo].[AdKeyElement] (
    [AdKeyElementID] INT           IDENTITY (1, 1) NOT NULL,
    [AdID]           INT           NOT NULL,
    [KeyElementID]   INT           NOT NULL,
    [AnsVarchar]     VARCHAR (MAX) NULL,
    [AnsMemo]        NTEXT         NULL,
    [AnsNumeric]     DECIMAL (18)  NULL,
    [AnsTimestamp]   DATETIME      NULL,
    [AnsBoolean]     TINYINT       NULL,
    [AnsConfigValue] VARCHAR (50)  NULL,
    [Active]         TINYINT       NULL,
    [KETemplateID]   INT           NULL
);

