CREATE TABLE [dbo].[RefKETemplateLog] (
    [LogTimeStamp]    DATETIME      NULL,
    [LogDMLOperation] CHAR (1)      NULL,
    [LoginUser]       VARCHAR (32)  NULL,
    [RefKETemplateID] INT           NULL,
    [Descrip]         VARCHAR (125) NULL,
    [KElementLevel]   VARCHAR (50)  NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

