CREATE TABLE [dbo].[RefElementCriteriaLog] (
    [LogTimeStamp]         DATETIME      NULL,
    [LogDMLOperation]      CHAR (1)      NULL,
    [LoginUser]            VARCHAR (32)  NULL,
    [RefElementCriteriaID] INT           NULL,
    [CriteriaTitle]        VARCHAR (100) NULL,
    [OldVal_CriteriaTitle] VARCHAR (100) NULL,
    [KETemplateID]         INT           NULL,
    [OldVal_KETemplateID]  INT           NULL,
    [ExpireDT]             DATETIME      NULL,
    [OldVal_ExpireDT]      DATETIME      NULL,
    [CTLegacyID]           INT           NULL,
    [OldVal_CTLegacyID]    INT           NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

