CREATE TABLE [dbo].[ElementCriteriaConditionLog] (
    [LogTimeStamp]        DATETIME      NULL,
    [LogDMLOperation]     CHAR (1)      NULL,
    [LoginUser]           VARCHAR (32)  NULL,
    [CriteriaConditionID] INT           NULL,
    [CriteriaID]          INT           NULL,
    [CompoundORInd]       BIT           NULL,
    [ConditionID]         INT           NULL,
    [ConditionIDList]     VARCHAR (MAX) NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

