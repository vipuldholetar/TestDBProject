CREATE TABLE [dbo].[MSMQServer] (
    [MSMQServerID] BIGINT        IDENTITY (1, 1) NOT NULL,
    [ServerIP]     NVARCHAR (50) NULL,
    [Status]       TINYINT       NULL,
    [CreatedByID]  BIGINT        NULL,
    [CreatedDT]    DATETIME      NULL
);

