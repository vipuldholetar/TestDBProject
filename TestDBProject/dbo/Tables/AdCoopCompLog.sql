CREATE TABLE [dbo].[AdCoopCompLog] (
    [LogTimeStamp]    DATETIME      NULL,
    [LogDMLOperation] CHAR (1)      NULL,
    [LoginUser]       VARCHAR (32)  NULL,
    [AdCoopID]        INT           NULL,
    [CoopCompCode]    NVARCHAR (50) NULL,
    [AdvertiserID]    INT           NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

