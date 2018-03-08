CREATE TABLE [dbo].[zOLD_EmailClickDetailLog] (
    [LogTimeStamp]       DATETIME      NULL,
    [LogDMLOperation]    CHAR (1)      NULL,
    [LoginUser]          VARCHAR (32)  NULL,
    [EmailClickDetailID] INT           NULL,
    [VehicleID]          VARCHAR (50)  NULL,
    [Descrip]            VARCHAR (500) NULL,
    [MaxOccurURL]        VARCHAR (500) NULL,
    [MaxOccurCount]      VARCHAR (50)  NULL,
    [HTMLPagePath]       VARCHAR (100) NULL,
    [ClickStartTime]     DATETIME      NULL,
    [ClickEndTime]       DATETIME      NULL,
    [CreateDT]           DATETIME      NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

