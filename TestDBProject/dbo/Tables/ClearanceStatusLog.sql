﻿CREATE TABLE [dbo].[ClearanceStatusLog] (
    [LogTimeStamp]      DATETIME      NULL,
    [LogDMLOperation]   CHAR (1)      NULL,
    [LoginUser]         VARCHAR (32)  NULL,
    [ClearanceStatusID] INT           NULL,
    [Status]            VARCHAR (50)  NULL,
    [OldVal_Status]     VARCHAR (50)  NULL,
    [Descrip]           VARCHAR (100) NULL,
    [OldVal_Descrip]    VARCHAR (100) NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

