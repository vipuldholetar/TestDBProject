CREATE TABLE [dbo].[WWTIndustryAdvertiserLog] (
    [LogTimeStamp]        DATETIME     NULL,
    [LogDMLOperation]     CHAR (1)     NULL,
    [LoginUser]           VARCHAR (32) NULL,
    [WWTIndustryID]       INT          NULL,
    [AdvertiserID]        INT          NULL,
    [OldVal_AdvertiserID] INT          NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

