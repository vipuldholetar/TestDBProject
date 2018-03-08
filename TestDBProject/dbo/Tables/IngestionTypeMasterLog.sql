CREATE TABLE [dbo].[IngestionTypeMasterLog] (
    [LogTimeStamp]        DATETIME      NULL,
    [LogDMLOperation]     CHAR (1)      NULL,
    [LoginUser]           VARCHAR (32)  NULL,
    [IngestionTypeID]     INT           NULL,
    [Descrip]             VARCHAR (100) NULL,
    [OldVal_Descrip]      VARCHAR (100) NULL,
    [CreatedDT]           DATETIME      NULL,
    [OldVal_CreatedDT]    DATETIME      NULL,
    [CreatedByID]         INT           NULL,
    [OldVal_CreatedByID]  INT           NULL,
    [ModifyDT]            DATETIME      NULL,
    [OldVal_ModifyDT]     DATETIME      NULL,
    [ModifiedByID]        INT           NULL,
    [OldVal_ModifiedByID] INT           NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

