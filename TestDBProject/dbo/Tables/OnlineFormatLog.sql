CREATE TABLE [dbo].[OnlineFormatLog] (
    [LogTimeStamp]      DATETIME       NULL,
    [LogDMLOperation]   CHAR (1)       NULL,
    [LoginUser]         VARCHAR (32)   NULL,
    [OnlineFormatID]    INT            NULL,
    [Name]              VARCHAR (60)   NULL,
    [OnlineFormatCODE]  VARCHAR (10)   NULL,
    [HorizontalSize]    NUMERIC (5)    NULL,
    [VerticalSize]      NUMERIC (5)    NULL,
    [CreatedDT]         DATETIME       NULL,
    [ModifiedDT]        DATETIME       NULL,
    [CpmCalcFormatCODE] VARCHAR (10)   NULL,
    [CostAdjustFactor]  NUMERIC (3, 2) NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

