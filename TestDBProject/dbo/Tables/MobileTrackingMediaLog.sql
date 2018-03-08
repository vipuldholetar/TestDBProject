CREATE TABLE [dbo].[MobileTrackingMediaLog] (
    [LogTimeStamp]          DATETIME     NULL,
    [LogDMLOperation]       CHAR (1)     NULL,
    [LoginUser]             VARCHAR (32) NULL,
    [MobileTrackingMediaID] INT          NULL,
    [WebsiteID]             INT          NULL,
    [OldVal_WebsiteID]      INT          NULL,
    [MobileAppID]           INT          NULL,
    [OldVal_MobileAppID]    INT          NULL,
    [TrackStartDate]        DATE         NULL,
    [OldVal_TrackStartDate] DATE         NULL,
    [TrackEndDate]          DATE         NULL,
    [OldVal_TrackEndDate]   DATE         NULL,
    [CreateDT]              DATETIME     NULL,
    [OldVal_CreateDT]       DATETIME     NULL,
    [ModifyDT]              DATETIME     NULL,
    [OldVal_ModifyDT]       DATETIME     NULL,
    [CTLegacySeq]           INT          NULL,
    [OldVal_CTLegacySeq]    INT          NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

