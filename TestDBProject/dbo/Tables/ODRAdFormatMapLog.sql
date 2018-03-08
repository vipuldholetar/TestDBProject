CREATE TABLE [dbo].[ODRAdFormatMapLog] (
    [LogTimeStamp]           DATETIME      NULL,
    [LogDMLOperation]        CHAR (1)      NULL,
    [LoginUser]              VARCHAR (32)  NULL,
    [MTFormatID]             INT           NULL,
    [GroupID]                INT           NULL,
    [OldVal_GroupID]         INT           NULL,
    [FamilyID]               INT           NULL,
    [OldVal_FamilyID]        INT           NULL,
    [CMSSourceFormat]        VARCHAR (200) NULL,
    [OldVal_CMSSourceFormat] VARCHAR (200) NULL,
    [FormatDescrip]          VARCHAR (200) NULL,
    [OldVal_FormatDescrip]   VARCHAR (200) NULL,
    [CreatedDT]              DATETIME      NULL,
    [OldVal_CreatedDT]       DATETIME      NULL,
    [CreatedByID]            INT           NULL,
    [OldVal_CreatedByID]     INT           NULL,
    [ModifiedDT]             DATETIME      NULL,
    [OldVal_ModifiedDT]      DATETIME      NULL,
    [ModifiedByID]           INT           NULL,
    [OldVal_ModifiedByID]    INT           NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

