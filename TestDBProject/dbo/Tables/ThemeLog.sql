CREATE TABLE [dbo].[ThemeLog] (
    [LogTimeStamp]           DATETIME      NULL,
    [LogDMLOperation]        CHAR (1)      NULL,
    [LoginUser]              VARCHAR (32)  NULL,
    [ThemeID]                INT           NULL,
    [Descrip]                VARCHAR (100) NULL,
    [OldVal_Descrip]         VARCHAR (100) NULL,
    [StartDT]                DATETIME      NULL,
    [OldVal_StartDT]         DATETIME      NULL,
    [EndDT]                  DATETIME      NULL,
    [OldVal_EndDT]           DATETIME      NULL,
    [MTLegacyThemeID]        INT           NULL,
    [OldVal_MTLegacyThemeID] INT           NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

