CREATE TABLE [dbo].[CropCategoryGroupLog] (
    [LogTimeStamp]        DATETIME     NULL,
    [LogDMLOperation]     CHAR (1)     NULL,
    [LoginUser]           VARCHAR (32) NULL,
    [CropCategoryGroupID] INT          NULL,
    [CategoryGroupID]     INT          NULL,
    [CreateDT]            DATETIME     NULL,
    [CreatedByID]         INT          NULL,
    [ModifiedDT]          DATETIME     NULL,
    [ModifiedByID]        INT          NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

