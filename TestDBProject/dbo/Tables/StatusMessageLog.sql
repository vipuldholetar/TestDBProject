CREATE TABLE [dbo].[StatusMessageLog] (
    [LogTimeStamp]            DATETIME      NULL,
    [LogDMLOperation]         CHAR (1)      NULL,
    [LoginUser]               VARCHAR (32)  NULL,
    [StatusMessageID]         INT           NULL,
    [CreatedDT]               DATETIME      NULL,
    [OldVal_CreatedDT]        DATETIME      NULL,
    [MessageID]               VARCHAR (50)  NULL,
    [OldVal_MessageID]        VARCHAR (50)  NULL,
    [MessageType]             VARCHAR (50)  NULL,
    [OldVal_MessageType]      VARCHAR (50)  NULL,
    [Priority]                VARCHAR (20)  NULL,
    [OldVal_Priority]         VARCHAR (20)  NULL,
    [Source]                  VARCHAR (100) NULL,
    [OldVal_Source]           VARCHAR (100) NULL,
    [Target]                  VARCHAR (100) NULL,
    [OldVal_Target]           VARCHAR (100) NULL,
    [EventType]               VARCHAR (20)  NULL,
    [OldVal_EventType]        VARCHAR (20)  NULL,
    [EventDetailedXML]        VARCHAR (MAX) NULL,
    [OldVal_EventDetailedXML] VARCHAR (MAX) NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

