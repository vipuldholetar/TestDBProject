CREATE TABLE [dbo].[ActiveLock] (
    [EntityID]   VARCHAR (255) NOT NULL,
    [EntityName] VARCHAR (50)  NOT NULL,
    [FormName]   VARCHAR (100) NOT NULL,
    [LockedBy]   INT           NOT NULL,
    [LockDT]     DATETIME      NOT NULL,
    CONSTRAINT [PK_Entity] PRIMARY KEY CLUSTERED ([EntityID] ASC, [EntityName] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_ActiveLock-EntityIDLockedby]
    ON [dbo].[ActiveLock]([EntityID] ASC, [EntityName] ASC, [LockedBy] ASC)
    INCLUDE([FormName]);

