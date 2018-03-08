﻿CREATE TABLE [dbo].[AdLogStagingOutdoor_XXX] (
    [LogTimeStamp]                 DATETIME      NULL,
    [LogDMLOperation]              CHAR (1)      NULL,
    [LoginUser]                    VARCHAR (32)  NULL,
    [AdID]                         INT           NULL,
    [OriginalAdID]                 INT           NULL,
    [OldVal_OriginalAdID]          INT           NULL,
    [PrimaryOccurrenceID]          VARCHAR (MAX) NULL,
    [OldVal_PrimaryOccurrenceID]   VARCHAR (MAX) NULL,
    [AdvertiserID]                 INT           NULL,
    [OldVal_AdvertiserID]          INT           NULL,
    [BreakDT]                      DATETIME      NULL,
    [OldVal_BreakDT]               DATETIME      NULL,
    [StartDT]                      DATETIME      NULL,
    [OldVal_StartDT]               DATETIME      NULL,
    [EndDT]                        DATETIME      NULL,
    [OldVal_EndDT]                 DATETIME      NULL,
    [LanguageID]                   INT           NULL,
    [OldVal_LanguageID]            INT           NULL,
    [FamilyID]                     INT           NULL,
    [OldVal_FamilyID]              INT           NULL,
    [CommonAdDT]                   DATETIME      NULL,
    [OldVal_CommonAdDT]            DATETIME      NULL,
    [NoTakeAdReason]               INT           NULL,
    [OldVal_NoTakeAdReason]        INT           NULL,
    [FirstRunMarket]               VARCHAR (MAX) NULL,
    [OldVal_FirstRunMarket]        VARCHAR (MAX) NULL,
    [FirstRunDate]                 DATETIME      NULL,
    [OldVal_FirstRunDate]          DATETIME      NULL,
    [LastRunDate]                  DATETIME      NULL,
    [OldVal_LastRunDate]           DATETIME      NULL,
    [AdName]                       VARCHAR (MAX) NULL,
    [OldVal_AdName]                VARCHAR (MAX) NULL,
    [AdVisual]                     VARCHAR (MAX) NULL,
    [OldVal_AdVisual]              VARCHAR (MAX) NULL,
    [AdInfo]                       VARCHAR (MAX) NULL,
    [OldVal_AdInfo]                VARCHAR (MAX) NULL,
    [Coop1AdvId]                   VARCHAR (MAX) NULL,
    [OldVal_Coop1AdvId]            VARCHAR (MAX) NULL,
    [Coop2AdvId]                   VARCHAR (MAX) NULL,
    [OldVal_Coop2AdvId]            VARCHAR (MAX) NULL,
    [Coop3AdvId]                   VARCHAR (MAX) NULL,
    [OldVal_Coop3AdvId]            VARCHAR (MAX) NULL,
    [Comp1AdvId]                   VARCHAR (MAX) NULL,
    [OldVal_Comp1AdvId]            VARCHAR (MAX) NULL,
    [Comp2AdvId]                   VARCHAR (MAX) NULL,
    [OldVal_Comp2AdvId]            VARCHAR (MAX) NULL,
    [TaglineId]                    VARCHAR (MAX) NULL,
    [OldVal_TaglineId]             VARCHAR (MAX) NULL,
    [LeadText]                     VARCHAR (MAX) NULL,
    [OldVal_LeadText]              VARCHAR (MAX) NULL,
    [LeadAvHeadline]               VARCHAR (MAX) NULL,
    [OldVal_LeadAvHeadline]        VARCHAR (MAX) NULL,
    [RecutDetail]                  VARCHAR (MAX) NULL,
    [OldVal_RecutDetail]           VARCHAR (MAX) NULL,
    [RecutAdId]                    INT           NULL,
    [OldVal_RecutAdId]             INT           NULL,
    [EthnicFlag]                   VARCHAR (MAX) NULL,
    [OldVal_EthnicFlag]            VARCHAR (MAX) NULL,
    [AddlInfo]                     VARCHAR (MAX) NULL,
    [OldVal_AddlInfo]              VARCHAR (MAX) NULL,
    [AdLength]                     INT           NULL,
    [OldVal_AdLength]              INT           NULL,
    [InternalNotes]                VARCHAR (MAX) NULL,
    [OldVal_InternalNotes]         VARCHAR (MAX) NULL,
    [ProductId]                    INT           NULL,
    [OldVal_ProductId]             INT           NULL,
    [Description]                  VARCHAR (MAX) NULL,
    [OldVal_Description]           VARCHAR (MAX) NULL,
    [SessionDate]                  DATETIME      NULL,
    [OldVal_SessionDate]           DATETIME      NULL,
    [Unclassified]                 BIT           NULL,
    [OldVal_Unclassified]          BIT           NULL,
    [CreateDate]                   DATETIME      NULL,
    [OldVal_CreateDate]            DATETIME      NULL,
    [CreatedBy]                    INT           NULL,
    [OldVal_CreatedBy]             INT           NULL,
    [ModifiedDate]                 DATETIME      NULL,
    [OldVal_ModifiedDate]          DATETIME      NULL,
    [ModifiedBy]                   INT           NULL,
    [OldVal_ModifiedBy]            INT           NULL,
    [Campaign]                     VARCHAR (MAX) NULL,
    [OldVal_Campaign]              VARCHAR (MAX) NULL,
    [KeyVisualElement]             VARCHAR (MAX) NULL,
    [OldVal_KeyVisualElement]      VARCHAR (MAX) NULL,
    [EntryEligible]                VARCHAR (MAX) NULL,
    [OldVal_EntryEligible]         VARCHAR (MAX) NULL,
    [AdType]                       VARCHAR (MAX) NULL,
    [OldVal_AdType]                VARCHAR (MAX) NULL,
    [AdDistribution]               VARCHAR (MAX) NULL,
    [OldVal_AdDistribution]        VARCHAR (MAX) NULL,
    [ClassifiedBy]                 VARCHAR (MAX) NULL,
    [OldVal_ClassifiedBy]          VARCHAR (MAX) NULL,
    [ClassifiedDT]                 DATETIME      NULL,
    [OldVal_ClassifiedDT]          DATETIME      NULL,
    [MarketID]                     INT           NULL,
    [OldVal_MarketID]              INT           NULL,
    [Query]                        INT           NULL,
    [OldVal_Query]                 INT           NULL,
    [AuditedByID]                  VARCHAR (MAX) NULL,
    [OldVal_AuditedByID]           VARCHAR (MAX) NULL,
    [AuditDT]                      DATE          NULL,
    [OldVal_AuditDT]               DATE          NULL,
    [CelebrityID]                  INT           NULL,
    [OldVal_CelebrityID]           INT           NULL,
    [ClassificationGroupID]        INT           NULL,
    [OldVal_ClassificationGroupID] INT           NULL,
    [CTLegacySEQ]                  INT           NULL,
    [OldVal_CTLegacySEQ]           INT           NULL,
    [CTLegacyAdCode]               VARCHAR (12)  NULL,
    [OldVal_CTLegacyAdCode]        VARCHAR (12)  NULL
);

