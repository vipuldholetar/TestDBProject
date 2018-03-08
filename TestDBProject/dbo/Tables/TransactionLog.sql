CREATE TABLE [dbo].[TransactionLog] (
    [TransactionLogID]    INT      IDENTITY (1, 1) NOT NULL,
    [ActivityLogID]       INT      NOT NULL,
    [TransactionID]       INT      NOT NULL,
    [StartDT]             DATETIME NOT NULL,
    [EndDT]               DATETIME NOT NULL,
    [UserID]              INT      NOT NULL,
    [AppID]               INT      NOT NULL,
    [ScreenID]            INT      NOT NULL,
    [OriginalTransaction] INT      NULL,
    PRIMARY KEY CLUSTERED ([TransactionLogID] ASC),
    CONSTRAINT [FK_TransactionLog_ActivityLog] FOREIGN KEY ([ActivityLogID]) REFERENCES [dbo].[ActivityLog] ([ActivityLogID]),
    CONSTRAINT [FK_TransactionLog_Screen] FOREIGN KEY ([ScreenID]) REFERENCES [dbo].[Screen] ([ScreenID]),
    CONSTRAINT [FK_TransactionLog_Transaction] FOREIGN KEY ([TransactionID]) REFERENCES [dbo].[Transaction] ([TransactionID]),
    CONSTRAINT [FK_TransactionLog_User] FOREIGN KEY ([UserID]) REFERENCES [dbo].[User] ([UserID])
);

