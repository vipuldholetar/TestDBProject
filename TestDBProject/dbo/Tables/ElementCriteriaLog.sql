CREATE TABLE [dbo].[ElementCriteriaLog] (
    [LogTimeStamp]           DATETIME     NULL,
    [LogDMLOperation]        CHAR (1)     NULL,
    [LoginUser]              VARCHAR (32) NULL,
    [CriteriaID]             INT          NULL,
    [CriteriaTitle]          VARCHAR (50) NULL,
    [OldVal_CriteriaTitle]   VARCHAR (50) NULL,
    [CriteriaFormula]        VARCHAR (50) NULL,
    [OldVal_CriteriaFormula] VARCHAR (50) NULL,
    [KETemplateID]           INT          NULL,
    [OldVal_KETemplateID]    INT          NULL,
    [ExpireDT]               DATETIME     NULL,
    [OldVal_ExpireDT]        DATETIME     NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

