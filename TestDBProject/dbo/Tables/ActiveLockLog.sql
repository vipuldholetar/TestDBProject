CREATE TABLE [dbo].[ActiveLockLog] (
    [LogTimeStamp]    DATETIME      NULL,
    [LogDMLOperation] CHAR (1)      NULL,
    [LoginUser]       VARCHAR (32)  NULL,
    [EntityID]        VARCHAR (50)  NULL,
    [OldVal_EntityID] VARCHAR (50)  NULL,
    [EntityName]      VARCHAR (50)  NULL,
    [FormName]        VARCHAR (100) NULL,
    [OldVal_FormName] VARCHAR (100) NULL,
    [LockedBy]        INT           NULL,
    [OldVal_LockedBy] INT           NULL,
    [LockDT]          DATETIME      NULL,
    [OldVal_LockDT]   DATETIME      NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

