CREATE TABLE [dbo].[RefTemplateElement] (
    [RefTemplateElementID] INT           IDENTITY (1, 1) NOT NULL,
    [KETemplateID]         INT           NOT NULL,
    [KeyElementID]         INT           NOT NULL,
    [ReqdInd]              TINYINT       NOT NULL,
    [DefaultValue]         VARCHAR (50)  NOT NULL,
    [GroupCode]            VARCHAR (50)  NOT NULL,
    [DisplayOrder]         INT           NOT NULL,
    [TemplateDescription]  VARCHAR (200) NULL,
    [ElementDescription]   VARCHAR (200) NULL,
    CONSTRAINT [PK_RefTemplateElement] PRIMARY KEY CLUSTERED ([RefTemplateElementID] ASC)
);

