CREATE TABLE [dbo].[MapMODConditionLog] (
    [LogTimeStamp]         DATETIME      NULL,
    [LogDMLOperation]      CHAR (1)      NULL,
    [LoginUser]            VARCHAR (32)  NULL,
    [MapMODConditionID]    INT           NULL,
    [ConditionCODE]        NVARCHAR (50) NULL,
    [OldVal_ConditionCODE] NVARCHAR (50) NULL,
    [Type]                 VARCHAR (50)  NULL,
    [OldVal_Type]          VARCHAR (50)  NULL,
    [EntityID]             INT           NULL,
    [OldVal_EntityID]      INT           NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

