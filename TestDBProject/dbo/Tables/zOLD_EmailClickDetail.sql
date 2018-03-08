CREATE TABLE [dbo].[zOLD_EmailClickDetail] (
    [EmailClickDetailID] INT           IDENTITY (1, 1) NOT NULL,
    [VehicleID]          VARCHAR (50)  NULL,
    [Descrip]            VARCHAR (500) NULL,
    [MaxOccurURL]        VARCHAR (500) NULL,
    [MaxOccurCount]      VARCHAR (50)  NULL,
    [HTMLPagePath]       VARCHAR (100) NULL,
    [ClickStartTime]     DATETIME      NULL,
    [ClickEndTime]       DATETIME      NULL,
    [CreateDT]           DATETIME      NULL
);

