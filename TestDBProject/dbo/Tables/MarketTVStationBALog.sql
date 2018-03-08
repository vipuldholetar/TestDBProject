CREATE TABLE [dbo].[MarketTVStationBALog] (
    [LogTimeStamp]    DATETIME       NULL,
    [LogDMLOperation] CHAR (1)       NULL,
    [LoginUser]       VARCHAR (32)   NULL,
    [STPSMarketCODE]  NVARCHAR (255) NULL,
    [STPStatCODE]     NVARCHAR (255) NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

