CREATE TABLE [dbo].[SenderPersonaLog] (
    [LogTimeStamp]              DATETIME      NULL,
    [LogDMLOperation]           CHAR (1)      NULL,
    [LoginUser]                 VARCHAR (32)  NULL,
    [SenderPersonaID]           INT           NULL,
    [SenderName]                VARCHAR (255) NULL,
    [OldVal_SenderName]         VARCHAR (255) NULL,
    [Email]                     VARCHAR (255) NULL,
    [OldVal_Email]              VARCHAR (255) NULL,
    [Gender]                    CHAR (10)     NULL,
    [OldVal_Gender]             CHAR (10)     NULL,
    [AgeBracket]                INT           NULL,
    [OldVal_AgeBracket]         INT           NULL,
    [AssignedMarketCode]        INT           NULL,
    [OldVal_AssignedMarketCode] INT           NULL,
    [StartDT]                   DATETIME      NULL,
    [OldVal_StartDT]            DATETIME      NULL,
    [EndDT]                     DATETIME      NULL,
    [OldVal_EndDT]              DATETIME      NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

