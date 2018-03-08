CREATE TABLE [dbo].[AdvertiserTypeLog] (
    [LogTimeStamp]     DATETIME     NULL,
    [LogDMLOperation]  CHAR (1)     NULL,
    [LoginUser]        VARCHAR (32) NULL,
    [AdvertiserTypeID] INT          NULL,
    [AdvertiserType]   VARCHAR (50) NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

