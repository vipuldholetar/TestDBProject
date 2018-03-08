CREATE TABLE [dbo].[TVMediaFileDataLog] (
    [LogTimeStamp]    DATETIME      NULL,
    [LogDMLOperation] CHAR (1)      NULL,
    [LoginUser]       VARCHAR (32)  NULL,
    [MediaFilePath]   VARCHAR (300) NULL,
    [MediaFileName]   VARCHAR (200) NULL,
    [FileSize]        BIGINT        NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

