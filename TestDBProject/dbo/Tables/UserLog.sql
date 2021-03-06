﻿CREATE TABLE [dbo].[UserLog] (
    [LogTimeStamp]       DATETIME         NULL,
    [LogDMLOperation]    CHAR (1)         NULL,
    [LoginUser]          VARCHAR (32)     NULL,
    [UserID]             INT              NULL,
    [Username]           VARCHAR (50)     NULL,
    [OldVal_Username]    VARCHAR (50)     NULL,
    [FName]              VARCHAR (50)     NULL,
    [OldVal_FName]       VARCHAR (50)     NULL,
    [LName]              VARCHAR (50)     NULL,
    [OldVal_LName]       VARCHAR (50)     NULL,
    [Inits]              VARCHAR (3)      NULL,
    [OldVal_Inits]       VARCHAR (3)      NULL,
    [ActiveInd]          TINYINT          NULL,
    [OldVal_ActiveInd]   TINYINT          NULL,
    [LocationID]         INT              NULL,
    [OldVal_LocationID]  INT              NULL,
    [IndHideUser]        TINYINT          NULL,
    [OldVal_IndHideUser] TINYINT          NULL,
    [EmailID]            VARCHAR (50)     NULL,
    [OldVal_EmailID]     VARCHAR (50)     NULL,
    [AuditRate]          NUMERIC (12, 10) NULL,
    [OldVal_AuditRate]   NUMERIC (12, 10) NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

