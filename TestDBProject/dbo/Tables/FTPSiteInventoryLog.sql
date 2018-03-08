CREATE TABLE [dbo].[FTPSiteInventoryLog] (
    [LogTimeStamp]           DATETIME      NULL,
    [LogDMLOperation]        CHAR (1)      NULL,
    [LoginUser]              VARCHAR (32)  NULL,
    [CMSFileName]            VARCHAR (200) NULL,
    [CMSFileSize]            INT           NULL,
    [OldVal_CMSFileSize]     INT           NULL,
    [CMSSourceFolder]        VARCHAR (200) NULL,
    [OldVal_CMSSourceFolder] VARCHAR (200) NULL,
    [CMSFileDate]            DATETIME      NULL,
    [OldVal_CMSFileDate]     DATETIME      NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

