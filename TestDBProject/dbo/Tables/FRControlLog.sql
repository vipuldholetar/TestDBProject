CREATE TABLE [dbo].[FRControlLog] (
    [LogTimeStamp]       DATETIME     NULL,
    [LogDMLOperation]    CHAR (1)     NULL,
    [LoginUser]          VARCHAR (32) NULL,
    [RetailerID]         INT          NULL,
    [MarketID]           INT          NULL,
    [OldVal_MarketID]    INT          NULL,
    [FRControlID]        INT          NULL,
    [OldVal_FRControlID] INT          NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

