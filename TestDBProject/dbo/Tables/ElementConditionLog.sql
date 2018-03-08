CREATE TABLE [dbo].[ElementConditionLog] (
    [LogTimeStamp]             DATETIME      NULL,
    [LogDMLOperation]          CHAR (1)      NULL,
    [LoginUser]                VARCHAR (32)  NULL,
    [ElementConditionID]       INT           NULL,
    [ConditionTitle]           VARCHAR (50)  NULL,
    [OldVal_ConditionTitle]    VARCHAR (50)  NULL,
    [AdLevelVariable]          VARCHAR (200) NULL,
    [OldVal_AdLevelVariable]   VARCHAR (200) NULL,
    [ConditionOperator]        VARCHAR (50)  NULL,
    [OldVal_ConditionOperator] VARCHAR (50)  NULL,
    [ConditionVariable]        VARCHAR (200) NULL,
    [OldVal_ConditionVariable] VARCHAR (200) NULL,
    [ExpireDT]                 DATETIME      NULL,
    [OldVal_ExpireDT]          DATETIME      NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

