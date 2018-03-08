CREATE TABLE [dbo].[RefTemplateElementsLog] (
    [LogTimeStamp]    DATETIME     NULL,
    [LogDMLOperation] CHAR (1)     NULL,
    [LoginUser]       VARCHAR (32) NULL,
    [KETemplateID]    INT          NULL,
    [KeyElementID]    INT          NULL,
    [ReqdInd]         TINYINT      NULL,
    [DefaultValue]    VARCHAR (50) NULL,
    [GroupCode]       VARCHAR (50) NULL,
    [DisplayOrder]    INT          NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

