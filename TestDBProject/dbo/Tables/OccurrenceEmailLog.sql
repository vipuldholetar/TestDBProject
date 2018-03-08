CREATE TABLE [dbo].[OccurrenceEmailLog] (
    [LogTimeStamp]    DATETIME      NULL,
    [LogDMLOperation] CHAR (1)      NULL,
    [LoginUser]       VARCHAR (32)  NULL,
    [OccurrenceID]    INT           NULL,
    [BodyHTML]        VARCHAR (MAX) NULL,
    [BodyText]        VARCHAR (MAX) NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

