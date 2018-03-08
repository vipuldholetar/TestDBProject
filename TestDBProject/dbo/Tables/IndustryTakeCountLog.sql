CREATE TABLE [dbo].[IndustryTakeCountLog] (
    [LogTimeStamp]          DATETIME     NULL,
    [LogDMLOperation]       CHAR (1)     NULL,
    [LoginUser]             VARCHAR (32) NULL,
    [IndustryTakeCountID]   INT          NULL,
    [WWTIndustryID]         INT          NULL,
    [OldVal_WWTIndustryID]  INT          NULL,
    [MediaStream]           VARCHAR (50) NULL,
    [OldVal_MediaStream]    VARCHAR (50) NULL,
    [PubUniverse]           VARCHAR (50) NULL,
    [OldVal_PubUniverse]    VARCHAR (50) NULL,
    [EthnicGroupID]         INT          NULL,
    [OldVal_EthnicGroupID]  INT          NULL,
    [LanguageID]            INT          NULL,
    [OldVal_LanguageID]     INT          NULL,
    [TakeCountLimit]        INT          NULL,
    [OldVal_TakeCountLimit] INT          NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

