CREATE TABLE [dbo].[COMTimePeriodLog] (
    [LogTimeStamp]             DATETIME      NULL,
    [LogDMLOperation]          CHAR (1)      NULL,
    [LoginUser]                VARCHAR (32)  NULL,
    [COMTimePeriodID]          INT           NULL,
    [Descrip]                  VARCHAR (100) NULL,
    [OldVal_Descrip]           VARCHAR (100) NULL,
    [StartDT]                  DATE          NULL,
    [OldVal_StartDT]           DATE          NULL,
    [EndDT]                    DATE          NULL,
    [OldVal_EndDT]             DATE          NULL,
    [CreatedDT]                DATE          NULL,
    [OldVal_CreatedDT]         DATE          NULL,
    [IngestionComplete]        TINYINT       NULL,
    [OldVal_IngestionComplete] TINYINT       NULL,
    [MarketID]                 INT           NULL,
    [OldVal_MarketID]          INT           NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

