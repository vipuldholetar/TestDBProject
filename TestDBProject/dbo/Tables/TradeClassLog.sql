CREATE TABLE [dbo].[TradeClassLog] (
    [LogTimeStamp]           DATETIME     NULL,
    [LogDMLOperation]        CHAR (1)     NULL,
    [LoginUser]              VARCHAR (32) NULL,
    [TradeClassID]           INT          NULL,
    [Descrip]                VARCHAR (50) NULL,
    [OldVal_Descrip]         VARCHAR (50) NULL,
    [NoFamilyInd]            TINYINT      NULL,
    [OldVal_NoFamilyInd]     TINYINT      NULL,
    [LimitedEntryInd]        TINYINT      NULL,
    [OldVal_LimitedEntryInd] TINYINT      NULL,
    [IndPageDT]              TINYINT      NULL,
    [OldVal_IndPageDT]       TINYINT      NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

