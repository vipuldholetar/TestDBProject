CREATE TABLE [dbo].[TVDaypartsRatesSYNLog] (
    [LogTimeStamp]               DATETIME         NULL,
    [LogDMLOperation]            CHAR (1)         NULL,
    [LoginUser]                  VARCHAR (32)     NULL,
    [TVDaypartRatesSYNId]        INT              NULL,
    [Distributor]                VARCHAR (50)     NULL,
    [OldVal_Distributor]         VARCHAR (50)     NULL,
    [TVDaypartTimeZoneId]        INT              NULL,
    [OldVal_TVDaypartTimeZoneId] INT              NULL,
    [Rate]                       NUMERIC (18, 10) NULL,
    [OldVal_Rate]                NUMERIC (18, 10) NULL,
    [EffectiveStartDate]         DATE             NULL,
    [OldVal_EffectiveStartDate]  DATE             NULL,
    [EffectiveEndDate]           DATE             NULL,
    [OldVal_EffectiveEndDate]    DATE             NULL,
    [ModifyDT]                   DATETIME         NULL,
    [OldVal_ModifyDT]            DATETIME         NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

