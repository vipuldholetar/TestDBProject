﻿CREATE TABLE [dbo].[AdMigrationStaging] (
    [AdID]                  INT           IDENTITY (1, 1) NOT NULL,
    [OriginalAdID]          INT           NULL,
    [PrimaryOccurrenceID]   VARCHAR (MAX) NULL,
    [AdvertiserID]          INT           NULL,
    [BreakDT]               DATETIME      NULL,
    [StartDT]               DATETIME      NULL,
    [EndDT]                 DATETIME      NULL,
    [LanguageID]            INT           NULL,
    [FamilyID]              INT           NULL,
    [CommonAdDT]            DATETIME      NULL,
    [NoTakeAdReason]        INT           NULL,
    [FirstRunMarket]        VARCHAR (MAX) NULL,
    [FirstRunDate]          DATETIME      NULL,
    [LastRunDate]           DATETIME      NULL,
    [AdName]                VARCHAR (MAX) NULL,
    [AdVisual]              VARCHAR (MAX) NULL,
    [AdInfo]                VARCHAR (MAX) NULL,
    [Coop1AdvId]            VARCHAR (MAX) NULL,
    [Coop2AdvId]            VARCHAR (MAX) NULL,
    [Coop3AdvId]            VARCHAR (MAX) NULL,
    [Comp1AdvId]            VARCHAR (MAX) NULL,
    [Comp2AdvId]            VARCHAR (MAX) NULL,
    [TaglineId]             VARCHAR (MAX) NULL,
    [LeadText]              VARCHAR (MAX) NULL,
    [LeadAvHeadline]        VARCHAR (MAX) NULL,
    [RecutDetail]           VARCHAR (MAX) NULL,
    [RecutAdId]             INT           NULL,
    [EthnicFlag]            VARCHAR (MAX) NULL,
    [AddlInfo]              VARCHAR (MAX) NULL,
    [AdLength]              INT           NULL,
    [InternalNotes]         VARCHAR (MAX) NULL,
    [ProductId]             INT           NULL,
    [Description]           VARCHAR (MAX) NULL,
    [SessionDate]           DATETIME      NULL,
    [Unclassified]          BIT           NULL,
    [CreateDate]            DATETIME      NULL,
    [CreatedBy]             INT           NULL,
    [ModifiedDate]          DATETIME      NULL,
    [ModifiedBy]            INT           NULL,
    [Campaign]              VARCHAR (MAX) NULL,
    [KeyVisualElement]      VARCHAR (MAX) NULL,
    [EntryEligible]         VARCHAR (MAX) NULL,
    [AdType]                VARCHAR (MAX) NULL,
    [AdDistribution]        VARCHAR (MAX) NULL,
    [CelebrityID]           INT           NULL,
    [ClassificationGroupID] INT           NULL,
    [ClassifiedBy]          VARCHAR (MAX) NULL,
    [ClassifiedDT]          DATETIME      NULL,
    [MarketID]              INT           NULL,
    [Query]                 INT           NULL,
    [AuditedByID]           VARCHAR (MAX) NULL,
    [AuditDT]               DATE          NULL,
    [CTLegacySEQ]           INT           NULL,
    [CTLegacyAdCode]        VARCHAR (12)  NULL,
    [CTInstCode]            VARCHAR (6)   NULL,
    [CTProdCode]            VARCHAR (10)  NULL,
    [CTOriginalAdCode]      VARCHAR (12)  NULL,
    [CTRecutAdCode]         VARCHAR (12)  NULL,
    [TargetMarketCode]      VARCHAR (1)   NULL
);
