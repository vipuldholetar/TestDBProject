CREATE TABLE [dbo].[RefElementCriteriaConditionLog] (
    [LogTimeStamp]               DATETIME      NULL,
    [LogDMLOperation]            CHAR (1)      NULL,
    [LoginUser]                  VARCHAR (32)  NULL,
    [ElementCriteriaConditionID] INT           NULL,
    [ElementCriteriaID]          INT           NULL,
    [CompoundORInd]              BIT           NULL,
    [ConditionID]                INT           NULL,
    [ConditionIDList]            VARCHAR (MAX) NULL,
    [FromElementCondition]       VARCHAR (MAX) NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

