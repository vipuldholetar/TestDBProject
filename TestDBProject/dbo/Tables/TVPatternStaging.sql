﻿CREATE TABLE [dbo].[TVPatternStaging] (
    [PatternStagingID]         INT           IDENTITY (1, 1) NOT NULL,
    [PatternID]                INT           NULL,
    [CreativeStgID]            INT           NULL,
    [Priority]                 INT           NULL,
    [MediaStream]              VARCHAR (50)  NULL,
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
    [CreatedDT]                DATETIME      NOT NULL,
    [CreatedByID]              INT           NOT NULL,
    [ModifiedDT]               DATETIME      NULL,
    [ModifiedByID]             INT           NULL,
    [WorkType]                 INT           NULL,
    [ScoreQ]                   INT           NULL,
    [MediaOutlet]              VARCHAR (20)  NULL,
    [OldID]                    INT           NULL,
    [FormatCODE]               VARCHAR (20)  NULL,
    [AuditedByID]              INT           NULL,
    [AuditedDT]                DATETIME      NULL,
    [AdvertiserNameSuggestion] VARCHAR (50)  NULL
);

