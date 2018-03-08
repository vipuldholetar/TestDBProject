CREATE TABLE [dbo].[PatternODRStaging] (
    [PatternODRStagingID]   INT           IDENTITY (1, 1) NOT NULL,
    [CreativeStgID]         INT           NULL,
    [CreativeSignatureCODE] VARCHAR (200) NOT NULL,
    [TotalQScore]           INT           NULL,
    [ScoreQ]                INT           NULL,
    [LanguageID]            INT           NULL,
    [Query]                 TINYINT       NULL,
    [Exception]             TINYINT       NULL,
    [CreatedDT]             DATETIME      NOT NULL,
    [CreatedByID]           INT           NOT NULL,
    [ModifiedDT]            DATETIME      NULL,
    [ModifiedByID]          INT           NULL,
    [AuditByID]             INT           NULL,
    [AuditedDT]             DATETIME      NULL,
    CONSTRAINT [PK_PatternMasterStagingODR] PRIMARY KEY CLUSTERED ([PatternODRStagingID] ASC),
    CONSTRAINT [FK_PatternMasterStagingODR_PatternMasterStagingODR] FOREIGN KEY ([PatternODRStagingID]) REFERENCES [dbo].[PatternODRStaging] ([PatternODRStagingID])
);

