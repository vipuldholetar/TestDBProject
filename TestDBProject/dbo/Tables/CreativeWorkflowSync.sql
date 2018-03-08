CREATE TABLE [dbo].[CreativeWorkflowSync] (
    [id]                     BIGINT IDENTITY (1, 1) NOT NULL,
    [creativemodificationid] BIGINT NULL,
    [creativesyncstatusid]   INT    NULL,
    [locationid]             INT    NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

