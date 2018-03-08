CREATE TABLE [dbo].[Inventory] (
    [InventoryID]             INT          IDENTITY (1, 1) NOT NULL,
    [ActivityID]              INT          NOT NULL,
    [ScreenId]                INT          NOT NULL,
    [TransactionType]         VARCHAR (50) NOT NULL,
    [TransactionID]           TINYINT      NOT NULL,
    [CreatedDT]               DATETIME     NOT NULL,
    [CaptureActivityDuration] TINYINT      NOT NULL,
    [GeneralTransaction]      TINYINT      NOT NULL,
    [AdCount]                 TINYINT      NOT NULL,
    [OccrncCreationCount]     TINYINT      NOT NULL,
    [AdErrorCount]            TINYINT      NOT NULL,
    [OccrncErrorCount]        TINYINT      NOT NULL,
    CONSTRAINT [PK__Inventor__F4A24BC27507E966] PRIMARY KEY CLUSTERED ([InventoryID] ASC),
    CONSTRAINT [FK_Inventory_Activity] FOREIGN KEY ([ActivityID]) REFERENCES [dbo].[Activity] ([ActivityID])
);

