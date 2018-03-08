CREATE TABLE [dbo].[ActivityLog] (
    [ActivityLogID] INT      IDENTITY (1, 1) NOT NULL,
    [ActivityID]    INT      NOT NULL,
    [StartDT]       DATETIME NOT NULL,
    [EndDT]         DATETIME NOT NULL,
    [UserID]        INT      NOT NULL,
    [AppID]         INT      NOT NULL,
    [ScreenID]      INT      NOT NULL,
    PRIMARY KEY CLUSTERED ([ActivityLogID] ASC),
    CONSTRAINT [FK_ActivityLog_Activity] FOREIGN KEY ([ActivityID]) REFERENCES [dbo].[Activity] ([ActivityID]),
    CONSTRAINT [FK_ActivityLog_Screen] FOREIGN KEY ([ScreenID]) REFERENCES [dbo].[Screen] ([ScreenID]),
    CONSTRAINT [FK_ActivityLog_User] FOREIGN KEY ([UserID]) REFERENCES [dbo].[User] ([UserID])
);

