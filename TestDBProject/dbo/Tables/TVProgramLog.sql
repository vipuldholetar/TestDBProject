CREATE TABLE [dbo].[TVProgramLog] (
    [LogTimeStamp]             DATETIME         NULL,
    [LogDMLOperation]          CHAR (1)         NULL,
    [LoginUser]                VARCHAR (32)     NULL,
    [TVProgramID]              INT              NULL,
    [ProgramName]              VARCHAR (250)    NULL,
    [OldVal_ProgramName]       VARCHAR (250)    NULL,
    [TVStationID]              INT              NULL,
    [OldVal_TVStationID]       INT              NULL,
    [CTLegacyCode]             VARCHAR (5)      NULL,
    [OldVal_CTLegacyCode]      VARCHAR (5)      NULL,
    [TVProgramTypeCode]        VARCHAR (1)      NULL,
    [OldVal_TVProgramTypeCode] VARCHAR (1)      NULL,
    [LanguageID]               INT              NULL,
    [OldVal_LanguageID]        INT              NULL,
    [CostFlag]                 VARCHAR (1)      NULL,
    [OldVal_CostFlag]          VARCHAR (1)      NULL,
    [Cost]                     NUMERIC (16, 10) NULL,
    [OldVal_Cost]              NUMERIC (16, 10) NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

