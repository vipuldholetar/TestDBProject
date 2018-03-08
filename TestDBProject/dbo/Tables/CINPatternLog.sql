CREATE TABLE [dbo].[CINPatternLog] (
    [LogTimeStamp]      DATETIME      NULL,
    [LogDMLOperation]   CHAR (1)      NULL,
    [LoginUser]         VARCHAR (32)  NULL,
    [CINPatternID]      BIGINT        NULL,
    [CreativeID]        VARCHAR (200) NULL,
    [OldVal_CreativeID] VARCHAR (200) NULL,
    [AirDT]             DATETIME      NULL,
    [OldVal_AirDT]      DATETIME      NULL,
    [CustomerID]        INT           NULL,
    [OldVal_CustomerID] INT           NULL,
    [Rating]            VARCHAR (200) NULL,
    [OldVal_Rating]     VARCHAR (200) NULL,
    [Length]            INT           NULL,
    [OldVal_Length]     INT           NULL,
    [CreatedDT]         DATETIME      NULL,
    [OldVal_CreatedDT]  DATETIME      NULL,
    [ModifiedDT]        DATETIME      NULL,
    [OldVal_ModifiedDT] DATETIME      NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

