CREATE TABLE [dbo].[TVDaypartRatesNetworkLog] (
    [LogTimeStamp]               DATETIME         NULL,
    [LogDMLOperation]            CHAR (1)         NULL,
    [LoginUser]                  VARCHAR (32)     NULL,
    [TVDaypartRatesNetworkId]    INT              NULL,
    [TVStationId]                INT              NULL,
    [OldVal_TVStationId]         INT              NULL,
    [TVDaypartTimeZoneId]        INT              NULL,
    [OldVal_TVDaypartTimeZoneId] INT              NULL,
    [ProgramSubCatId]            INT              NULL,
    [OldVal_ProgramSubCatId]     INT              NULL,
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

