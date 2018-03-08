CREATE TABLE [dbo].[COMWebsiteKeyMeasureLog] (
    [LogTimeStamp]           DATETIME     NULL,
    [LogDMLOperation]        CHAR (1)     NULL,
    [LoginUser]              VARCHAR (32) NULL,
    [COMWebsiteKeyMeasureID] INT          NULL,
    [SiteID]                 INT          NULL,
    [OldVal_SiteID]          INT          NULL,
    [UniqueVisitors]         DECIMAL (18) NULL,
    [OldVal_UniqueVisitors]  DECIMAL (18) NULL,
    [MinutesVisited]         DECIMAL (18) NULL,
    [OldVal_MinutesVisited]  DECIMAL (18) NULL,
    [PagesViewed]            DECIMAL (18) NULL,
    [OldVal_PagesViewed]     DECIMAL (18) NULL,
    [TotalVisits]            DECIMAL (18) NULL,
    [OldVal_TotalVisits]     DECIMAL (18) NULL,
    [TimePeriodID]           INT          NULL,
    [OldVal_TimePeriodID]    INT          NULL,
    [IngestionDT]            DATE         NULL,
    [OldVal_IngestionDT]     DATE         NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

