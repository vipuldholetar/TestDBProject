CREATE TYPE [dbo].[MultiMapApprovalList] AS TABLE (
    [RowID]                 INT            NULL,
    [OriginalPatternCode]   NVARCHAR (MAX) NULL,
    [AdId]                  INT            NULL,
    [ApprovedForAllMarkets] BIT            NULL,
    [MarketID]              INT            NULL,
    [Status]                NVARCHAR (MAX) NULL,
    [MediaStream]           NVARCHAR (MAX) NULL,
    [EffectiveEndDate]      DATETIME       NULL,
    [EffectiveStartDate]    DATETIME       NULL);

