CREATE TABLE [dbo].[ScreenLog] (
    [LogTimeStamp]         DATETIME      NULL,
    [LogDMLOperation]      CHAR (1)      NULL,
    [LoginUser]            VARCHAR (32)  NULL,
    [ScreenID]             INT           NULL,
    [FormName]             VARCHAR (50)  NULL,
    [OldVal_FormName]      VARCHAR (50)  NULL,
    [Functionality]        VARCHAR (200) NULL,
    [OldVal_Functionality] VARCHAR (200) NULL,
    [ObjectName]           VARCHAR (200) NULL,
    [OldVal_ObjectName]    VARCHAR (200) NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

