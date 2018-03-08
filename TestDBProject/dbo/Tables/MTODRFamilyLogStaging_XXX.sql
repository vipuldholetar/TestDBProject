CREATE TABLE [dbo].[MTODRFamilyLogStaging_XXX] (
    [LogTimeStamp]         DATETIME       NULL,
    [LogDMLOperation]      CHAR (1)       NULL,
    [LoginUser]            VARCHAR (32)   NULL,
    [MTODRFamilyID]        INT            NULL,
    [FamilyDescrip]        VARCHAR (1000) NULL,
    [OldVal_FamilyDescrip] VARCHAR (1000) NULL,
    [CreatedDT]            DATETIME       NULL,
    [OldVal_CreatedDT]     DATETIME       NULL,
    [CreatedByID]          INT            NULL,
    [OldVal_CreatedByID]   INT            NULL,
    [ModifiedDT]           DATETIME       NULL,
    [OldVal_ModifiedDT]    DATETIME       NULL,
    [ModifiedByID]         INT            NULL,
    [OldVal_ModifiedByID]  INT            NULL
);

