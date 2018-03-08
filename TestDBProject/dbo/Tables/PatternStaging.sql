CREATE TABLE [dbo].[PatternStaging] (
    [PatternStagingID]         INT           IDENTITY (1, 1) NOT NULL,
    [PatternID]                INT           NULL,
    [CreativeStgID]            INT           NULL,
    [Priority]                 INT           NULL,
    [MediaStream]              INT           NULL,
    [Exception]                TINYINT       NULL,
    [ExceptionText]            VARCHAR (MAX) NULL,
    [Query]                    TINYINT       NULL,
    [QueryCategory]            INT           NULL,
    [QueryText]                VARCHAR (MAX) NULL,
    [QueryAnswer]              VARCHAR (MAX) NULL,
    [TakeReasonCODE]           VARCHAR (MAX) NULL,
    [NoTakeReasonCODE]         VARCHAR (MAX) NULL,
    [Status]                   VARCHAR (50)  NOT NULL,
    [AutoIndexing]             TINYINT       NULL,
    [CreativeIdAcIdUseCase]    CHAR (2)      NULL,
    [LanguageID]               INT           NULL,
    [CreatedDT]                DATETIME      CONSTRAINT [DF_PatternMasterStg_CreateDate] DEFAULT (getdate()) NOT NULL,
    [CreatedByID]              INT           CONSTRAINT [DF_PatternMasterStg_CreateBy] DEFAULT ((1)) NOT NULL,
    [ModifiedDT]               DATETIME      NULL,
    [ModifiedByID]             INT           NULL,
    [WorkType]                 INT           NULL,
    [ScoreQ]                   INT           NULL,
    [MediaOutlet]              VARCHAR (20)  NULL,
    [OldID]                    INT           NULL,
    [FormatCODE]               VARCHAR (20)  NULL,
    [AuditedByID]              INT           NULL,
    [AuditedDT]                DATETIME      NULL,
    [AdvertiserNameSuggestion] VARCHAR (256) NULL,
    [CreativeSignature]        VARCHAR (200) NULL,
    CONSTRAINT [PK_PatternMasterStgRA] PRIMARY KEY CLUSTERED ([PatternStagingID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_PatternStaging_ToPattern] FOREIGN KEY ([PatternID]) REFERENCES [dbo].[Pattern] ([PatternID])
);


GO
CREATE NONCLUSTERED INDEX [IDX_IsException]
    ON [dbo].[PatternStaging]([Exception] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_IsQuery]
    ON [dbo].[PatternStaging]([Query] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [IDX_WorkType]
    ON [dbo].[PatternStaging]([WorkType] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [<IDX_MediaStream>]
    ON [dbo].[PatternStaging]([MediaStream] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20160202-134653]
    ON [dbo].[PatternStaging]([MediaStream] ASC, [LanguageID] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [IX_PatternStaging_MediaStreamLanguageCreativeStgID]
    ON [dbo].[PatternStaging]([MediaStream] ASC, [LanguageID] ASC, [CreativeStgID] ASC, [PatternID] ASC, [CreativeSignature] ASC, [AutoIndexing] ASC)
    INCLUDE([PatternStagingID], [Exception], [Query], [WorkType], [ScoreQ], [MediaOutlet], [AuditedByID], [AuditedDT], [NoTakeReasonCODE], [QueryAnswer]);


GO
CREATE NONCLUSTERED INDEX [IX_PatternStaging_AuditedById]
    ON [dbo].[PatternStaging]([AuditedByID] ASC);


GO
CREATE NONCLUSTERED INDEX [IXPatternStaging_CreativeSignature]
    ON [dbo].[PatternStaging]([CreativeSignature] ASC)
    INCLUDE([CreativeStgID], [LanguageID]);


GO
CREATE NONCLUSTERED INDEX [IDX_PATTERNSTAGING_PatternID]
    ON [dbo].[PatternStaging]([PatternID] ASC)
    INCLUDE([Exception]);


GO
CREATE NONCLUSTERED INDEX [idx_CreativeStgID]
    ON [dbo].[PatternStaging]([CreativeStgID] ASC)
    INCLUDE([PatternStagingID]);

