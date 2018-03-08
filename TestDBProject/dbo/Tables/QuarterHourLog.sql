CREATE TABLE [dbo].[QuarterHourLog] (
    [LogTimeStamp]     DATETIME     NULL,
    [LogDMLOperation]  CHAR (1)     NULL,
    [LoginUser]        VARCHAR (32) NULL,
    [QuarterHourID]    INT          NULL,
    [StartTime]        TIME (7)     NULL,
    [OldVal_StartTime] TIME (7)     NULL,
    [EndTime]          TIME (7)     NULL,
    [OldVal_EndTime]   TIME (7)     NULL,
    [CreatedDT]        DATETIME     NULL,
    [OldVal_CreatedDT] DATETIME     NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

