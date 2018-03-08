CREATE TABLE [dbo].[CommercialSyndicationDataLog] (
    [LogTimeStamp]    DATETIME       NULL,
    [LogDMLOperation] CHAR (1)       NULL,
    [LoginUser]       VARCHAR (32)   NULL,
    [Value]           NVARCHAR (MAX) NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

