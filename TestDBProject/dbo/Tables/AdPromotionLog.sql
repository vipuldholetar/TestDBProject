CREATE TABLE [dbo].[AdPromotionLog] (
    [LogTimeStamp]    DATETIME       NULL,
    [LogDMLOperation] CHAR (1)       NULL,
    [LoginUser]       VARCHAR (32)   NULL,
    [AdPromotionID]   INT            NULL,
    [RecordID]        INT            NULL,
    [RecordType]      NVARCHAR (MAX) NULL,
    [CreatedDT]       DATETIME       NULL,
    [CreatedByID]     INT            NULL,
    [ModifiedDT]      DATETIME       NULL,
    [ModifiedByID]    INT            NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

