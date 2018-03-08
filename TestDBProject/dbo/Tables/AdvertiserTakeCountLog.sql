CREATE TABLE [dbo].[AdvertiserTakeCountLog] (
    [LogTimeStamp]          DATETIME     NULL,
    [LogDMLOperation]       CHAR (1)     NULL,
    [LoginUser]             VARCHAR (32) NULL,
    [AdvertiserTakeCountID] INT          NULL,
    [WWTIndustryID]         INT          NULL,
    [OldVal_WWTIndustryID]  INT          NULL,
    [AdvertiserID]          INT          NULL,
    [OldVal_AdvertiserID]   INT          NULL,
    [MediaStream]           VARCHAR (50) NULL,
    [OldVal_MediaStream]    VARCHAR (50) NULL,
    [PubUniverse]           VARCHAR (50) NULL,
    [OldVal_PubUniverse]    VARCHAR (50) NULL,
    [LanguageID]            INT          NULL,
    [OldVal_LanguageID]     INT          NULL,
    [TakeCountLimit]        INT          NULL,
    [OldVal_TakeCountLimit] INT          NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

