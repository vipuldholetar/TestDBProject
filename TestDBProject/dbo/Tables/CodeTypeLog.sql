﻿CREATE TABLE [dbo].[CodeTypeLog] (
    [LogTimeStamp]    DATETIME     NULL,
    [LogDMLOperation] CHAR (1)     NULL,
    [LoginUser]       VARCHAR (32) NULL,
    [CodeTypeID]      INT          NULL,
    [Descrip]         VARCHAR (50) NULL,
    [OldVal_Descrip]  VARCHAR (50) NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

