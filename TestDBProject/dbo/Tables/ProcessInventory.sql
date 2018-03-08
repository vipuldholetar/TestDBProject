CREATE TABLE [dbo].[ProcessInventory] (
    [ProcessInventoryID] INT             IDENTITY (1, 1) NOT NULL,
    [ProcessCODE]        VARCHAR (20)    NOT NULL,
    [ProcessGroup]       VARCHAR (200)   NULL,
    [Name]               VARCHAR (200)   NOT NULL,
    [Descrip]            NVARCHAR (1000) NOT NULL,
    [Type]               VARCHAR (10)    NOT NULL,
    [Status]             VARCHAR (10)    NOT NULL,
    [ParentProcessID]    VARCHAR (20)    NULL,
    [CreatedDT]          DATETIME        NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_ProcessInventory_Column]
    ON [dbo].[ProcessInventory]([ProcessCODE] ASC);

