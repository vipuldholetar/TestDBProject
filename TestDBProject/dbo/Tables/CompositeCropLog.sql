CREATE TABLE [dbo].[CompositeCropLog] (
    [LogTimeStamp]              DATETIME       NULL,
    [LogDMLOperation]           CHAR (1)       NULL,
    [LoginUser]                 VARCHAR (32)   NULL,
    [CompositeCropID]           INT            NULL,
    [CreativeCropID]            INT            NULL,
    [OldVal_CreativeCropID]     INT            NULL,
    [CompositeImageSize]        INT            NULL,
    [OldVal_CompositeImageSize] INT            NULL,
    [CreatedDT]                 DATETIME       NULL,
    [OldVal_CreatedDT]          DATETIME       NULL,
    [CreatedByID]               INT            NULL,
    [OldVal_CreatedByID]        INT            NULL,
    [Score]                     INT            NULL,
    [OldVal_Score]              INT            NULL,
    [AuditedBy]                 NVARCHAR (MAX) NULL,
    [OldVal_AuditedBy]          NVARCHAR (MAX) NULL,
    [AuditedDT]                 DATETIME       NULL,
    [OldVal_AuditedDT]          DATETIME       NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

