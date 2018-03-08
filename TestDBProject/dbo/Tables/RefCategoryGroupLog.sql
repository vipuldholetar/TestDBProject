CREATE TABLE [dbo].[RefCategoryGroupLog] (
    [LogTimeStamp]                 DATETIME     NULL,
    [LogDMLOperation]              CHAR (1)     NULL,
    [LoginUser]                    VARCHAR (32) NULL,
    [RefCategoryGroupID]           INT          NULL,
    [ClassificationGroupID]        INT          NULL,
    [OldVal_ClassificationGroupID] INT          NULL,
    [CategoryGroupName]            VARCHAR (50) NULL,
    [OldVal_CategoryGroupName]     VARCHAR (50) NULL,
    [CreateDT]                     DATETIME     NULL,
    [OldVal_CreateDT]              DATETIME     NULL,
    [CreatedByID]                  INT          NULL,
    [OldVal_CreatedByID]           INT          NULL,
    [ModifiedDT]                   DATETIME     NULL,
    [OldVal_ModifiedDT]            DATETIME     NULL,
    [ModifiedByID]                 INT          NULL,
    [OldVal_ModifiedByID]          INT          NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

