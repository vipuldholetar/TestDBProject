CREATE TABLE [dbo].[TVDaypartTimeZoneLog] (
    [LogTimeStamp]         DATETIME     NULL,
    [LogDMLOperation]      CHAR (1)     NULL,
    [LoginUser]            VARCHAR (32) NULL,
    [TVDaypartTimeZoneID]  INT          NULL,
    [Code]                 VARCHAR (2)  NULL,
    [OldVal_Code]          VARCHAR (2)  NULL,
    [Name]                 VARCHAR (50) NULL,
    [OldVal_Name]          VARCHAR (50) NULL,
    [TimeZone]             VARCHAR (3)  NULL,
    [OldVal_TimeZone]      VARCHAR (3)  NULL,
    [DaysOfTheWeek]        VARCHAR (7)  NULL,
    [OldVal_DaysOfTheWeek] VARCHAR (7)  NULL,
    [StartTime]            TIME (7)     NULL,
    [OldVal_StartTime]     TIME (7)     NULL,
    [EndTime]              TIME (7)     NULL,
    [OldVal_EndTime]       TIME (7)     NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

