CREATE TABLE [dbo].[ODRMarketMapBADataLog] (
    [LogTimeStamp]           DATETIME       NULL,
    [LogDMLOperation]        CHAR (1)       NULL,
    [LoginUser]              VARCHAR (32)   NULL,
    [ODRMarketMapBADataCODE] NVARCHAR (255) NULL,
    [CMSMarketName]          NVARCHAR (255) NULL,
    [MTMarketCODE]           NVARCHAR (255) NULL,
    [ODRCMSCCreateDT]        DATETIME       NULL,
    [ODRCMSCEModifiedDT]     DATETIME       NULL,
    [ODRCMSCStatus]          NVARCHAR (255) NULL,
    [ODRCMSCStartTrackDT]    NVARCHAR (255) NULL,
    [ODRCMSCODRCMSFSeq]      NVARCHAR (255) NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

