CREATE TABLE [dbo].[StatusSMSLookupLog] (
    [LogTimeStamp]         DATETIME      NULL,
    [LogDMLOperation]      CHAR (1)      NULL,
    [LoginUser]            VARCHAR (32)  NULL,
    [StatusSMSLookupID]    INT           NULL,
    [StatusText]           VARCHAR (50)  NULL,
    [OldVal_StatusText]    VARCHAR (50)  NULL,
    [StatusCode]           INT           NULL,
    [OldVal_StatusCode]    INT           NULL,
    [StatusDescrip]        VARCHAR (200) NULL,
    [OldVal_StatusDescrip] VARCHAR (200) NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

