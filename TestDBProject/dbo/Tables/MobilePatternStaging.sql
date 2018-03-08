﻿CREATE TABLE [dbo].[MobilePatternStaging] (
    [PatternID]                INT           IDENTITY (1, 1) NOT NULL,
    [CreativeID]               INT           NULL,
    [AdID]                     INT           NULL,
    [MediaStream]              INT           NULL,
    [Exception]                TINYINT       NULL,
    [Priority]                 INT           NULL,
    [ExceptionText]            VARCHAR (50)  NULL,
    [Query]                    TINYINT       NULL,
    [QueryCategory]            INT           NULL,
    [QueryText]                VARCHAR (50)  NULL,
    [QueryAnswer]              VARCHAR (MAX) NULL,
    [TakeReasonCode]           VARCHAR (50)  NULL,
    [NoTakeReasonCode]         VARCHAR (50)  NULL,
    [Status]                   VARCHAR (50)  NOT NULL,
    [EventID]                  INT           NULL,
    [ThemeID]                  INT           NULL,
    [SalesStartDT]             DATETIME      NULL,
    [SalesEndDT]               DATETIME      NULL,
    [FlashInd]                 TINYINT       NULL,
    [NationalIndicator]        TINYINT       NULL,
    [CreateBy]                 INT           NULL,
    [CreateDate]               DATETIME      NULL,
    [ModifiedBy]               INT           NULL,
    [ModifyDate]               DATETIME      NULL,
    [EditInits]                INT           NULL,
    [LastMappedDate]           DATETIME      NULL,
    [LastMapperInits]          INT           NULL,
    [CouponIndicator]          BIT           NULL,
    [CreativeSignature]        VARCHAR (200) NULL,
    [AuditBy]                  VARCHAR (50)  NULL,
    [AuditDate]                DATETIME      NULL,
    [AdvertiserNameSuggestion] VARCHAR (50)  NULL
);

