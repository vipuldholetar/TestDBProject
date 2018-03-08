CREATE TABLE [dbo].[CodeLog] (
    [LogTimeStamp]           DATETIME     NULL,
    [LogDMLOperation]        CHAR (1)     NULL,
    [LoginUser]              VARCHAR (32) NULL,
    [CodeID]                 INT          NULL,
    [Descrip]                VARCHAR (50) NULL,
    [OldVal_Descrip]         VARCHAR (50) NULL,
    [CodeTypeID]             INT          NULL,
    [OldVal_CodeTypeID]      INT          NULL,
    [InternalDescrip]        VARCHAR (50) NULL,
    [OldVal_InternalDescrip] VARCHAR (50) NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

