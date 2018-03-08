CREATE TABLE [dbo].[OccurenceMediaTypeLog] (
    [LogTimeStamp]         DATETIME     NULL,
    [LogDMLOperation]      CHAR (1)     NULL,
    [LoginUser]            VARCHAR (32) NULL,
    [OccurenceMediaTypeID] INT          NULL,
    [MediaType]            VARCHAR (50) NULL,
    [OldVal_MediaType]     VARCHAR (50) NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

