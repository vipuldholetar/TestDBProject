CREATE TABLE [dbo].[CWF_SyncLog] (
    [MediaStream] VARCHAR (50) NOT NULL,
    [LastRunDT]   DATETIME     NOT NULL,
    CONSTRAINT [PK_CWF_SyncLog] PRIMARY KEY CLUSTERED ([MediaStream] ASC)
);

