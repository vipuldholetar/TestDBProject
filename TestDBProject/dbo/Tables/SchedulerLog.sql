CREATE TABLE [dbo].[SchedulerLog] (
    [LogTimeStamp]        DATETIME       NULL,
    [LogDMLOperation]     CHAR (1)       NULL,
    [LoginUser]           VARCHAR (32)   NULL,
    [SchedulerID]         INT            NULL,
    [ProcessGroup]        VARCHAR (200)  NULL,
    [ProcessID]           VARCHAR (200)  NULL,
    [Type]                VARCHAR (200)  NULL,
    [CurrentScheduleType] VARCHAR (200)  NULL,
    [ProcessName]         VARCHAR (200)  NULL,
    [StartDT]             DATETIME       NULL,
    [EndDT]               DATETIME       NULL,
    [OccurrenceTime]      VARCHAR (200)  NULL,
    [DayOfTheWeek]        VARCHAR (1000) NULL,
    [Enabled]             TINYINT        NULL,
    [CreatedDT]           DATETIME       NULL,
    [CreatedByID]         VARCHAR (200)  NULL,
    [ModifiedDT]          DATETIME       NULL,
    [ModifiedByID]        VARCHAR (200)  NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

