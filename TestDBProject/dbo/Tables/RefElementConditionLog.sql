CREATE TABLE [dbo].[RefElementConditionLog] (
    [LogTimeStamp]              DATETIME       NULL,
    [LogDMLOperation]           CHAR (1)       NULL,
    [LoginUser]                 VARCHAR (32)   NULL,
    [RefElementConditionID]     INT            NULL,
    [ConditionTitle]            VARCHAR (100)  NULL,
    [OldVal_ConditionTitle]     VARCHAR (100)  NULL,
    [AdLevelVariable]           VARCHAR (50)   NULL,
    [OldVal_AdLevelVariable]    VARCHAR (50)   NULL,
    [ConditionOperator]         VARCHAR (50)   NULL,
    [OldVal_ConditionOperator]  VARCHAR (50)   NULL,
    [ConditionVariable]         VARCHAR (2000) NULL,
    [OldVal_ConditionVariable]  VARCHAR (2000) NULL,
    [ExpireDT]                  DATETIME       NULL,
    [OldVal_ExpireDT]           DATETIME       NULL,
    [CTLegacyConditions]        VARCHAR (2000) NULL,
    [OldVal_CTLegacyConditions] VARCHAR (2000) NULL,
    [CTLegacyID]                INT            NULL,
    [OldVal_CTLegacyID]         INT            NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

