CREATE TABLE [dbo].[RefTaglineLog] (
    [LogTimeStamp]        DATETIME       NULL,
    [LogDMLOperation]     CHAR (1)       NULL,
    [LoginUser]           VARCHAR (32)   NULL,
    [RefTaglineID]        INT            NULL,
    [AdvertiserID]        INT            NULL,
    [OldVal_AdvertiserID] INT            NULL,
    [Tagline]             VARCHAR (1000) NULL,
    [OldVal_Tagline]      VARCHAR (1000) NULL,
    [Display]             INT            NULL,
    [OldVal_Display]      INT            NULL,
    [CreatedDT]           DATETIME       NULL,
    [OldVal_CreatedDT]    DATETIME       NULL,
    [CreateByID]          INT            NULL,
    [OldVal_CreateByID]   INT            NULL,
    [ModifiedDT]          DATETIME       NULL,
    [OldVal_ModifiedDT]   DATETIME       NULL,
    [ModifiedByID]        INT            NULL,
    [OldVal_ModifiedByID] INT            NULL,
    [CTLegacySEQ]         INT            NULL,
    [OldVal_CTLegacySEQ]  INT            NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

