CREATE TABLE [dbo].[WWTRuleLog] (
    [LogTimeStamp]         DATETIME     NULL,
    [LogDMLOperation]      CHAR (1)     NULL,
    [LoginUser]            VARCHAR (32) NULL,
    [WWTRuleID]            INT          NULL,
    [RuleTypeID]           INT          NULL,
    [OldVal_RuleTypeID]    INT          NULL,
    [WWTRuleNoteID]        INT          NULL,
    [OldVal_WWTRuleNoteID] INT          NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

