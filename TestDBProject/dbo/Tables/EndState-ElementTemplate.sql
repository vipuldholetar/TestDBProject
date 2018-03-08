CREATE TABLE [dbo].[EndState-ElementTemplate] (
    [FK_KETemplateID] VARCHAR (50)  NULL,
    [TemplateDesc]    VARCHAR (500) NULL,
    [FK_KeyElementID] VARCHAR (50)  NULL,
    [KeyElementDesc]  VARCHAR (50)  NULL,
    [ReqdIndicator]   VARCHAR (50)  NULL,
    [DefaultValue]    VARCHAR (50)  NULL,
    [GroupCode]       VARCHAR (50)  NULL,
    [DisplayOrder]    VARCHAR (50)  NULL
);

