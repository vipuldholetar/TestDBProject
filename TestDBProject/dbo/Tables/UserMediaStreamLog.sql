CREATE TABLE [dbo].[UserMediaStreamLog] (
    [LogTimeStamp]    DATETIME      NULL,
    [LogDMLOperation] CHAR (1)      NULL,
    [LoginUser]       VARCHAR (32)  NULL,
    [MediaStream]     NVARCHAR (50) NULL,
    [UserID]          INT           NULL,
    [CreatedDT]       DATETIME      NULL,
    [CreatedByID]     INT           NULL,
    [ModifiedDT]      DATETIME      NULL,
    [ModifiedByID]    INT           NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

