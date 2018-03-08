CREATE TABLE [dbo].[RefClassificationGroupLog] (
    [LogTimeStamp]                   DATETIME     NULL,
    [LogDMLOperation]                CHAR (1)     NULL,
    [LoginUser]                      VARCHAR (32) NULL,
    [RefClassificationGroupID]       INT          NULL,
    [ClassificationGroupCODE]        VARCHAR (1)  NULL,
    [OldVal_ClassificationGroupCODE] VARCHAR (1)  NULL,
    [ClassificationGroupName]        VARCHAR (50) NULL,
    [OldVal_ClassificationGroupName] VARCHAR (50) NULL,
    [CreatedDT]                      DATETIME     NULL,
    [OldVal_CreatedDT]               DATETIME     NULL,
    [CreateByID]                     INT          NULL,
    [OldVal_CreateByID]              INT          NULL,
    [ModifiedDT]                     DATETIME     NULL,
    [OldVal_ModifiedDT]              DATETIME     NULL,
    [ModifiedByID]                   INT          NULL,
    [OldVal_ModifiedByID]            INT          NULL,
    [CTLegacyMcerInitsCODE]          VARCHAR (3)  NULL,
    [OldVal_CTLegacyMcerInitsCODE]   VARCHAR (3)  NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

