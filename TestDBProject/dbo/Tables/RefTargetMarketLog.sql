CREATE TABLE [dbo].[RefTargetMarketLog] (
    [LogTimeStamp]      DATETIME     NULL,
    [LogDMLOperation]   CHAR (1)     NULL,
    [LoginUser]         VARCHAR (32) NULL,
    [RefTargetMarketID] INT          NULL,
    [Code]              VARCHAR (1)  NULL,
    [Name]              VARCHAR (50) NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

