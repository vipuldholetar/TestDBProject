CREATE TABLE [dbo].[AdProductLog] (
    [LogTimeStamp]      DATETIME     NULL,
    [LogDMLOperation]   CHAR (1)     NULL,
    [LoginUser]         VARCHAR (32) NULL,
    [AdProductID]       INT          NULL,
    [AdID]              INT          NULL,
    [OldVal_AdID]       INT          NULL,
    [ProductID]         INT          NULL,
    [OldVal_ProductID]  INT          NULL,
    [CreateDate]        DATETIME     NULL,
    [OldVal_CreateDate] DATETIME     NULL,
    [CreatedBy]         INT          NULL,
    [OldVal_CreatedBy]  INT          NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

