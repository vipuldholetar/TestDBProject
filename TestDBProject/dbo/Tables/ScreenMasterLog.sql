CREATE TABLE [dbo].[ScreenMasterLog] (
    [LogTimeStamp]        DATETIME     NULL,
    [LogDMLOperation]     CHAR (1)     NULL,
    [LoginUser]           VARCHAR (32) NULL,
    [ScreenMasterID]      INT          NULL,
    [Name]                VARCHAR (50) NULL,
    [OldVal_Name]         VARCHAR (50) NULL,
    [Description]         VARCHAR (50) NULL,
    [OldVal_Description]  VARCHAR (50) NULL,
    [CreatedDT]           DATETIME     NULL,
    [OldVal_CreatedDT]    DATETIME     NULL,
    [CreatedByID]         INT          NULL,
    [OldVal_CreatedByID]  INT          NULL,
    [ModifiedDT]          DATETIME     NULL,
    [OldVal_ModifiedDT]   DATETIME     NULL,
    [ModifiedByID]        INT          NULL,
    [OldVal_ModifiedByID] INT          NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

