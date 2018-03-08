CREATE TABLE [dbo].[WWTRuleNoteLog] (
    [LogTimeStamp]    DATETIME      NULL,
    [LogDMLOperation] CHAR (1)      NULL,
    [LoginUser]       VARCHAR (32)  NULL,
    [WWTRuleNoteID]   INT           NULL,
    [RuleNote]        VARCHAR (100) NULL,
    [OldVal_RuleNote] VARCHAR (100) NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

