CREATE TABLE [dbo].[PatternCINStaging] (
    [PatternCINStagingID]     INT           IDENTITY (1, 1) NOT NULL,
    [CreativeMasterStagingID] INT           NULL,
    [CreativeSignatureCODE]   VARCHAR (200) NOT NULL,
    [TotalQScore]             INT           NULL,
    [ScoreQ]                  INT           NULL,
    [LanguageID]              INT           NOT NULL,
    [IsQuery]                 TINYINT       NULL,
    [IsException]             TINYINT       NULL,
    [CreateDTM]               DATETIME      NOT NULL,
    [CreatedBy]               INT           NOT NULL,
    [ModifiedDTM]             DATETIME      NULL,
    [ModifiedBy]              INT           NULL,
    [AuditBy]                 INT           NULL,
    [AuditDTM]                DATETIME      NULL,
    CONSTRAINT [PK_PatternMasterStagingCIN] PRIMARY KEY CLUSTERED ([PatternCINStagingID] ASC)
);

