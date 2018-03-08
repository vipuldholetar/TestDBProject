CREATE TABLE [dbo].[AdvertiserMarketLog] (
    [LogTimeStamp]       DATETIME     NULL,
    [LogDMLOperation]    CHAR (1)     NULL,
    [LoginUser]          VARCHAR (32) NULL,
    [AdvertiserID]       INT          NULL,
    [MarketID]           INT          NULL,
    [AllMarketIndicator] BIT          NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

