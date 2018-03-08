CREATE TABLE [dbo].[AdvertiserOldLog] (
    [LogTimeStamp]      DATETIME     NULL,
    [LogDMLOperation]   CHAR (1)     NULL,
    [LoginUser]         VARCHAR (32) NULL,
    [AdvertiserID]      INT          NULL,
    [Advertiser]        VARCHAR (50) NULL,
    [OldVal_Advertiser] VARCHAR (50) NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

