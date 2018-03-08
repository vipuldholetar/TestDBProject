﻿CREATE TABLE [dbo].[SizeLog] (
    [LogTimeStamp]          DATETIME      NULL,
    [LogDMLOperation]       CHAR (1)      NULL,
    [LoginUser]             VARCHAR (32)  NULL,
    [SizeID]                INT           NULL,
    [SizingMethodID]        INT           NULL,
    [OldVal_SizingMethodID] INT           NULL,
    [PubTypeID]             INT           NULL,
    [OldVal_PubTypeID]      INT           NULL,
    [Height]                FLOAT (53)    NULL,
    [OldVal_Height]         FLOAT (53)    NULL,
    [Width]                 FLOAT (53)    NULL,
    [OldVal_Width]          FLOAT (53)    NULL,
    [SizeDescrip]           VARCHAR (255) NULL,
    [OldVal_SizeDescrip]    VARCHAR (255) NULL,
    [CreatedDT]             DATETIME      NULL,
    [OldVal_CreatedDT]      DATETIME      NULL,
    [CreatedByID]           INT           NULL,
    [OldVal_CreatedByID]    INT           NULL,
    [ModifiedDT]            DATETIME      NULL,
    [OldVal_ModifiedDT]     DATETIME      NULL,
    [ModifiedByID]          INT           NULL,
    [OldVal_ModifiedByID]   INT           NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);
