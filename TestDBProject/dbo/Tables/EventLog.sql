CREATE TABLE [dbo].[EventLog] (
    [LogTimeStamp]                   DATETIME      NULL,
    [LogDMLOperation]                CHAR (1)      NULL,
    [LoginUser]                      VARCHAR (32)  NULL,
    [EventID]                        INT           NULL,
    [Descrip]                        VARCHAR (MAX) NULL,
    [OldVal_Descrip]                 VARCHAR (MAX) NULL,
    [StartDT]                        DATETIME      NULL,
    [OldVal_StartDT]                 DATETIME      NULL,
    [EndDT]                          DATETIME      NULL,
    [OldVal_EndDT]                   DATETIME      NULL,
    [MTLegacyEventID]                INT           NULL,
    [OldVal_MTLegacyEventID]         INT           NULL,
    [CTLegacyELMLTELValue]           VARCHAR (1)   NULL,
    [OldVal_CTLegacyELMLTELValue]    VARCHAR (1)   NULL,
    [FK_CTLegacyELMLTELLabel]        VARCHAR (50)  NULL,
    [OldVal_FK_CTLegacyELMLTELLabel] VARCHAR (50)  NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

