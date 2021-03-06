﻿CREATE TABLE [dbo].[ExceptionDetailLog] (
    [LogTimeStamp]                  DATETIME      NULL,
    [LogDMLOperation]               CHAR (1)      NULL,
    [LoginUser]                     VARCHAR (32)  NULL,
    [ExceptionDetailID]             INT           NULL,
    [PatternMasterStagingID]        INT           NULL,
    [OldVal_PatternMasterStagingID] INT           NULL,
    [PatternMasterID]               INT           NULL,
    [OldVal_PatternMasterID]        INT           NULL,
    [MediaStream]                   VARCHAR (MAX) NULL,
    [OldVal_MediaStream]            VARCHAR (MAX) NULL,
    [ExceptionType]                 VARCHAR (MAX) NULL,
    [OldVal_ExceptionType]          VARCHAR (MAX) NULL,
    [ExceptionStatus]               VARCHAR (MAX) NULL,
    [OldVal_ExceptionStatus]        VARCHAR (MAX) NULL,
    [ExcRaisedBy]                   INT           NULL,
    [OldVal_ExcRaisedBy]            INT           NULL,
    [ExcRaisedOn]                   DATETIME      NULL,
    [OldVal_ExcRaisedOn]            DATETIME      NULL,
    [CreatedDT]                     DATETIME      NULL,
    [OldVal_CreatedDT]              DATETIME      NULL,
    [CreatedByID]                   INT           NULL,
    [OldVal_CreatedByID]            INT           NULL,
    [ModifiedDT]                    DATETIME      NULL,
    [OldVal_ModifiedDT]             DATETIME      NULL,
    [ModifiedByID]                  INT           NULL,
    [OldVal_ModifiedByID]           INT           NULL,
    [AssignedToID]                  INT           NULL,
    [OldVal_AssignedToID]           INT           NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

