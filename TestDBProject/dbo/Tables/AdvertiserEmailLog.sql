CREATE TABLE [dbo].[AdvertiserEmailLog] (
    [LogTimeStamp]        DATETIME      NULL,
    [LogDMLOperation]     CHAR (1)      NULL,
    [LoginUser]           VARCHAR (32)  NULL,
    [AdvertiserEmailID]   INT           NULL,
    [AdvertiserID]        INT           NULL,
    [OldVal_AdvertiserID] INT           NULL,
    [MarketID]            INT           NULL,
    [OldVal_MarketID]     INT           NULL,
    [Email]               VARCHAR (200) NULL,
    [OldVal_Email]        VARCHAR (200) NULL,
    [CreatedDT]           DATETIME      NULL,
    [OldVal_CreatedDT]    DATETIME      NULL,
    [CreatedByID]         INT           NULL,
    [OldVal_CreatedByID]  INT           NULL,
    [ModifiedDT]          DATETIME      NULL,
    [OldVal_ModifiedDT]   DATETIME      NULL,
    [ModifiedByID]        INT           NULL,
    [OldVal_ModifiedByID] INT           NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

