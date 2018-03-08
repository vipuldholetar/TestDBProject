CREATE TABLE [dbo].[PatternTVStaging] (
    [PatternStagingTVID] INT           IDENTITY (1, 1) NOT NULL,
    [CreativeStagingID]  INT           NULL,
    [CreativeSignature]  VARCHAR (200) NOT NULL,
    [ScoreQ]             INT           NULL,
    [Query]              TINYINT       NULL,
    [Exception]          TINYINT       NULL,
    [LanguageID]         TINYINT       NULL,
    [MOTReasonCode]      VARCHAR (100) NULL,
    [NoTakeReasonCode]   VARCHAR (100) NULL,
    [AuditBy]            INT           NULL,
    [AuditDTM]           DATETIME      NULL,
    CONSTRAINT [PK_PatternMasterStagingTV] PRIMARY KEY CLUSTERED ([PatternStagingTVID] ASC)
);

