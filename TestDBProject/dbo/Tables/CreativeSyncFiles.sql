CREATE TABLE [dbo].[CreativeSyncFiles] (
    [id]                     BIGINT        IDENTITY (1, 1) NOT NULL,
    [basepath]               VARCHAR (512) NULL,
    [filename]               VARCHAR (512) NULL,
    [filepath]               VARCHAR (512) NULL,
    [filedate]               DATETIME      NULL,
    [filesizeKB]             FLOAT (53)    NULL,
    [filesizeMB]             FLOAT (53)    NULL,
    [insertdt]               DATETIME      DEFAULT (getdate()) NULL,
    [available]              TINYINT       DEFAULT ((0)) NULL,
    [creativemodificationid] BIGINT        NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

